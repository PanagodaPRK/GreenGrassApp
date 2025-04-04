import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/utils/toast_util.dart';
import '../../reviews/models/comment.dart';
import '../../reviews/models/review.dart';
import '../models/book.dart';
import '../models/media_item.dart';
import '../models/movie.dart';
import '../models/song.dart';
import '../models/teledrama.dart';
import '../widgets/review_dialog.dart';

class MediaDetailsController extends GetxController {
  // Services
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = Get.find<AuthService>();

  // Data variables
  final mediaItem = Rx<MediaItem?>(null);
  final mediaType = ''.obs;
  final mediaId = ''.obs;
  final reviews = <Review>[].obs;
  final comments = <Comment>[].obs;
  final displayedReviews = <Review>[].obs;
  final userLikedReviews = <String>[].obs;
  final userLikedComments = <String>[].obs;
  final expandedReviews = <String>[].obs;
  final replyingToComment = Rx<Comment?>(null);

  // User cache for faster display
  final Map<String, Map<String, dynamic>> _userCache = {};

  // UI state variables
  final isLoading = true.obs;
  final isLoadingReviews = true.obs;
  final isLoadingComments = true.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;
  final showFullDescription = false.obs;
  final showAllReviews = false.obs;
  final isFavorite = false.obs;

  // Text controllers for comments
  final Map<String, TextEditingController> commentControllers = {};
  final replyController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    // Get arguments from navigation
    final args = Get.arguments;
    if (args != null && args is Map<String, dynamic>) {
      mediaId.value = args['id'] ?? '';
      mediaType.value = args['type'] ?? '';
    }

    // Load data
    loadMediaDetails();
  }

  @override
  void onClose() {
    // Dispose all text controllers
    for (final controller in commentControllers.values) {
      controller.dispose();
    }
    replyController.dispose();
    super.onClose();
  }

  // Get comment controller for a specific review
  TextEditingController getCommentController(String reviewId) {
    if (!commentControllers.containsKey(reviewId)) {
      commentControllers[reviewId] = TextEditingController();
    }
    return commentControllers[reviewId]!;
  }

  // Load media details
  Future<void> loadMediaDetails() async {
    if (mediaId.isEmpty || mediaType.isEmpty) {
      hasError.value = true;
      errorMessage.value = 'Invalid media ID or type';
      isLoading.value = false;
      return;
    }

    isLoading.value = true;
    hasError.value = false;

    try {
      // Get media details based on type
      final docSnapshot =
          await _firestore
              .collection('${mediaType.value}s') // pluralize collection name
              .doc(mediaId.value)
              .get();

      if (!docSnapshot.exists) {
        hasError.value = true;
        errorMessage.value = 'Media not found';
        isLoading.value = false;
        return;
      }

      // Create proper object based on media type
      final data = docSnapshot.data()!;
      switch (mediaType.value) {
        case 'movie':
          mediaItem.value = Movie.fromMap(data, docSnapshot.id);
          break;
        case 'teledrama':
          mediaItem.value = Teledrama.fromMap(data, docSnapshot.id);
          break;
        case 'song':
          mediaItem.value = Song.fromMap(data, docSnapshot.id);
          break;
        case 'book':
          mediaItem.value = Book.fromMap(data, docSnapshot.id);
          break;
        default:
          hasError.value = true;
          errorMessage.value = 'Unsupported media type';
          break;
      }

      // Check if this media is favorited by the user
      if (_authService.isLoggedIn) {
        final userFavorite =
            await _firestore
                .collection('users')
                .doc(_authService.currentUser!.uid)
                .collection('favorites')
                .doc('${mediaType.value}_${mediaId.value}')
                .get();

        isFavorite.value = userFavorite.exists;
      }

      // Load reviews
      await loadReviews();
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Error loading media details: $e';
      print('Error loading media details: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Fetch user details from Firestore or cache
  Future<Map<String, dynamic>> _getUserDetails(String userId) async {
    // Return from cache if already fetched
    if (_userCache.containsKey(userId)) {
      return _userCache[userId]!;
    }

    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;

        // Add to cache
        _userCache[userId] = {
          'userFullName':
              userData['fullName'] ?? userData['displayName'] ?? 'Anonymous',
          'userProfileImage': userData['profileImage'] ?? userData['photoURL'],
        };

        return _userCache[userId]!;
      } else {
        // User not found, use defaults
        _userCache[userId] = {
          'userFullName': 'Anonymous',
          'userProfileImage': null,
        };
        return _userCache[userId]!;
      }
    } catch (e) {
      print('Error fetching user details: $e');
      // Return default values on error
      return {'userFullName': 'Anonymous', 'userProfileImage': null};
    }
  }

  // Load reviews for this media
  //no error handle all
  Future<void> loadReviews() async {
    isLoadingReviews.value = true;

    try {
      // Simplified query construction
      Query reviewsQuery = _firestore
          .collection('reviews')
          .where('mediaId', isEqualTo: mediaId.value)
          .where('mediaType', isEqualTo: mediaType.value);

      // Conditional ordering to handle index issues
      try {
        reviewsQuery = reviewsQuery.orderBy('createdAt', descending: true);
      } catch (orderingError) {
        print('Warning: Could not order reviews by createdAt: $orderingError');
      }

      // Attempt to get reviews
      final reviewsSnapshot = await reviewsQuery.get();

      // Clear existing reviews
      reviews.clear();

      // Process reviews with robust error handling
      for (final doc in reviewsSnapshot.docs) {
        try {
          final data = doc.data() as Map<String, dynamic>;

          // Validate required fields
          if (_validateReviewData(data)) {
            // Fetch and augment user details
            final userId = data['userId'] as String;
            final userDetails = await _getUserDetails(userId);

            // Merge user details and ensure default values
            final processedData = _processReviewData(data, userDetails);

            // Create and add review
            reviews.add(Review.fromMap(processedData, doc.id));
          }
        } catch (e) {
          print('Error processing individual review ${doc.id}: $e');
        }
      }

      // Fallback sorting if ordering failed
      if (reviews.isNotEmpty) {
        reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      }

      // Load user's liked reviews
      await _loadUserLikedReviews();

      print('Loaded ${reviews.length} reviews');
      updateDisplayedReviews();
    } catch (e) {
      // Comprehensive error handling
      _handleReviewLoadingError(e);
    } finally {
      isLoadingReviews.value = false;
    }
  }

  // Helper method to validate review data
  bool _validateReviewData(Map<String, dynamic> data) {
    return data.containsKey('userId') &&
        data.containsKey('rating') &&
        data.containsKey('content');
  }

  // Helper method to process review data
  Map<String, dynamic> _processReviewData(
    Map<String, dynamic> data,
    Map<String, dynamic> userDetails,
  ) {
    // Ensure all fields have default values
    return {
      ...data,
      'userFullName': data['userFullName'] ?? userDetails['userFullName'],
      'userProfileImage':
          data['userProfileImage'] ?? userDetails['userProfileImage'],
      'likeCount': data['likeCount'] ?? 0,
      'commentCount': data['commentCount'] ?? 0,
      'createdAt': data['createdAt'] ?? Timestamp.now(),
      'updatedAt': data['updatedAt'] ?? Timestamp.now(),
    };
  }

  // Separate method for loading liked reviews
  Future<void> _loadUserLikedReviews() async {
    if (!_authService.isLoggedIn) return;

    try {
      final userId = _authService.currentUser!.uid;
      final likedReviewsSnapshot =
          await _firestore
              .collection('users')
              .doc(userId)
              .collection('likedReviews')
              .get();

      userLikedReviews.clear();
      userLikedReviews.addAll(likedReviewsSnapshot.docs.map((doc) => doc.id));

      print('User has liked ${userLikedReviews.length} reviews');
    } catch (e) {
      print('Error loading liked reviews: $e');
    }
  }

  // Centralized error handling
  void _handleReviewLoadingError(dynamic e) {
    final errorMessage = e.toString();

    if (errorMessage.contains('failed-precondition') &&
        errorMessage.contains('index')) {
      // Extract index creation URL
      final indexUrl = _extractIndexUrl(errorMessage);

      print('FIRESTORE INDEX REQUIRED: Create the index at $indexUrl');
      print('Collection: reviews');
      print(
        'Fields to index: mediaId (Ascending), mediaType (Ascending), createdAt (Descending)',
      );

      ToastUtil.showError(
        'Database index required. Check console for details.',
      );
    } else {
      ToastUtil.showError('Error loading reviews: $e');
    }

    print('Error loading reviews: $e');
  }

  // Helper to extract index URL from error message
  String _extractIndexUrl(String errorMessage) {
    final urlStart = errorMessage.indexOf('https://');
    final urlEnd = errorMessage.indexOf(' ', urlStart);

    return (urlStart >= 0 && urlEnd > urlStart)
        ? errorMessage.substring(
          urlStart,
          urlEnd > 0 ? urlEnd : errorMessage.length,
        )
        : 'Firebase console';
  }

  // Load comments for a specific review
  Future<void> loadComments(String reviewId) async {
    isLoadingComments.value = true;

    try {
      // Diagnostic check before querying
      await _validateReviewExists(reviewId);

      // Construct query with detailed error handling
      final commentsQuery = _firestore
          .collection('comments')
          .where('reviewId', isEqualTo: reviewId);

      // Attempt to get comments with comprehensive error catching
      final commentsSnapshot = await _safeGetComments(commentsQuery);

      // Process comments
      final processedComments = await _processComments(commentsSnapshot.docs);

      // Update comments list
      _updateCommentsList(reviewId, processedComments);

      // Load user's liked comments
      await _loadUserLikedComments();

      print('Loaded ${processedComments.length} comments for review $reviewId');
    } catch (e) {
      _handleCommentsLoadingError(e, reviewId);
    } finally {
      isLoadingComments.value = false;
    }
  }

  // Validate that the review document exists
  Future<void> _validateReviewExists(String reviewId) async {
    try {
      final reviewDoc =
          await _firestore.collection('reviews').doc(reviewId).get();

      if (!reviewDoc.exists) {
        throw Exception('Review document does not exist: $reviewId');
      }

      // Optional: Print review document data for debugging
      print('Review document data: ${reviewDoc.data()}');
    } catch (e) {
      print('Error validating review document: $e');
      throw Exception('Invalid review ID: $reviewId');
    }
  }

  // Safe comments retrieval with detailed error information
  Future<QuerySnapshot> _safeGetComments(Query commentsQuery) async {
    try {
      // Attempt to get comments
      final snapshot = await commentsQuery.get();

      // Diagnostic print of query parameters
      print('Comments Query Details:');
      print(
        'Collection: ${commentsQuery.firestore.collection('comments').path}',
      );
      print('Filters: ${commentsQuery.parameters}');

      // If no documents, log a warning
      if (snapshot.docs.isEmpty) {
        print('No comments found for the given review');
      }

      return snapshot;
    } catch (e) {
      // Detailed error logging
      print('Failed to retrieve comments:');
      print('Error Type: ${e.runtimeType}');
      print('Error Details: $e');

      // Try to get some diagnostic information about the comments collection
      await _diagnosticCommentsCollectionCheck();

      rethrow;
    }
  }

  // Diagnostic check of comments collection
  Future<void> _diagnosticCommentsCollectionCheck() async {
    try {
      // Try to get a sample document from the comments collection
      final sampleQuery = _firestore.collection('comments').limit(1);

      final sampleSnapshot = await sampleQuery.get();

      if (sampleSnapshot.docs.isNotEmpty) {
        final sampleDoc = sampleSnapshot.docs.first;
        print('Sample Comments Collection Document:');
        print('Document ID: ${sampleDoc.id}');
        print('Document Data: ${sampleDoc.data()}');
      } else {
        print('No documents found in comments collection');
      }
    } catch (e) {
      print('Error checking comments collection: $e');
    }
  }

  // Centralized error handling with enhanced diagnostics
  void _handleCommentsLoadingError(dynamic e, String reviewId) {
    final errorMessage = e.toString().toLowerCase();

    // Detailed error analysis
    print('=== COMMENTS LOADING ERROR ANALYSIS ===');
    print('Review ID: $reviewId');
    print('Error: $e');
    print('Error Type: ${e.runtimeType}');

    if (errorMessage.contains('invalid-argument')) {
      print('Potential Causes:');
      print('1. Incorrect field names in query');
      print('2. Mismatched data types');
      print('3. Invalid query construction');
    }

    // User-friendly error notification
    ToastUtil.showError('Unable to load comments. Please try again.');

    // Log the full error for backend investigation
    print('Detailed Error Logging: $e');
  }

  // Process individual comments with robust error handling
  Future<List<Comment>> _processComments(
    List<QueryDocumentSnapshot> docs,
  ) async {
    final List<Comment> processedComments = [];

    for (final doc in docs) {
      try {
        final data = doc.data() as Map<String, dynamic>;

        // Validate required fields
        if (_validateCommentData(data)) {
          // Fetch user details
          final userId = data['userId'] as String;
          final userDetails = await _getUserDetails(userId);

          // Augment comment data
          final processedData = _processCommentData(data, userDetails);

          // Create and add comment
          processedComments.add(Comment.fromMap(processedData, doc.id));
        }
      } catch (e) {
        print('Error processing individual comment ${doc.id}: $e');
      }
    }

    // Sort comments chronologically
    processedComments.sort((a, b) => a.createdAt.compareTo(b.createdAt));

    return processedComments;
  }

  // Validate comment data
  bool _validateCommentData(Map<String, dynamic> data) {
    return data.containsKey('userId') && data.containsKey('content');
  }

  // Process and standardize comment data
  Map<String, dynamic> _processCommentData(
    Map<String, dynamic> data,
    Map<String, dynamic> userDetails,
  ) {
    return {
      ...data,
      'userFullName': data['userFullName'] ?? userDetails['userFullName'],
      'userProfileImage':
          data['userProfileImage'] ?? userDetails['userProfileImage'],
      'likeCount': data['likeCount'] ?? 0,
      'replyCount': data['replyCount'] ?? 0,
      'createdAt': data['createdAt'] ?? Timestamp.now(),
      'updatedAt': data['updatedAt'] ?? Timestamp.now(),
    };
  }

  // Update comments list
  void _updateCommentsList(String reviewId, List<Comment> newComments) {
    // Remove existing comments for this review
    comments.removeWhere((comment) => comment.reviewId == reviewId);

    // Add new comments
    comments.addAll(newComments);
  }

  // Load user's liked comments
  Future<void> _loadUserLikedComments() async {
    if (!_authService.isLoggedIn) return;

    try {
      final userId = _authService.currentUser!.uid;
      final likedCommentsSnapshot =
          await _firestore
              .collection('users')
              .doc(userId)
              .collection('likedComments')
              .get();

      userLikedComments.clear();
      userLikedComments.addAll(likedCommentsSnapshot.docs.map((doc) => doc.id));

      print('User has liked ${userLikedComments.length} comments');
    } catch (e) {
      print('Error loading liked comments: $e');
    }
  }

  // Toggle showing full description
  void toggleDescription() {
    showFullDescription.value = !showFullDescription.value;
  }

  // Toggle between showing all reviews or just top ones
  void toggleReviewDisplay() {
    showAllReviews.value = !showAllReviews.value;
    updateDisplayedReviews();
  }

  // Update the displayed reviews based on current filter
  void updateDisplayedReviews() {
    if (showAllReviews.value) {
      displayedReviews.assignAll(reviews);
    } else {
      // Show top 3 reviews (sorted by likes or most recent)
      final sortedReviews = List<Review>.from(reviews);

      // Make sure we have at least one review
      if (sortedReviews.isEmpty) {
        displayedReviews.clear();
        return;
      }

      // Sort by like count in descending order
      sortedReviews.sort((a, b) => b.likeCount.compareTo(a.likeCount));

      // Take the top 3 or however many we have
      displayedReviews.assignAll(
        sortedReviews.take(sortedReviews.length < 3 ? sortedReviews.length : 3),
      );
    }

    print('Displaying ${displayedReviews.length} reviews');
  }

  // Toggle favorite status for this media
  Future<void> toggleFavorite() async {
    if (!_authService.isLoggedIn) {
      ToastUtil.showInfo('Please log in to favorite');
      return;
    }

    try {
      final userId = _authService.currentUser!.uid;
      final favoriteId = '${mediaType.value}_${mediaId.value}';
      final favoriteRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .doc(favoriteId);

      if (isFavorite.value) {
        // Remove from favorites
        await favoriteRef.delete();
        isFavorite.value = false;
        ToastUtil.showSuccess('Removed from favorites');
      } else {
        // Make sure mediaItem exists before trying to access it
        if (mediaItem.value == null) {
          ToastUtil.showError('Media item not found');
          return;
        }

        // Add to favorites with proper error handling for images
        await favoriteRef.set({
          'mediaId': mediaId.value,
          'mediaType': mediaType.value,
          'title': mediaItem.value?.title ?? 'Untitled',
          'imageUrl':
              mediaItem.value?.images != null &&
                      mediaItem.value!.images.isNotEmpty
                  ? mediaItem.value!.images[0]
                  : '',
          'createdAt': FieldValue.serverTimestamp(),
        });
        isFavorite.value = true;
        ToastUtil.showSuccess('Added to favorites');
      }
    } catch (e) {
      ToastUtil.showError('Error updating favorites: $e');
      print('Error updating favorites: $e');
    }
  }

  // Share this media
  void shareMedia() {
    // Implementation would use a share plugin
    ToastUtil.showInfo('Sharing is not implemented in this demo');
  }

  // Show dialog to add a review
  void showAddReviewDialog() {
    if (!_authService.isLoggedIn) {
      ToastUtil.showInfo('Please log in to review');
      return;
    }

    Get.dialog(
      ReviewDialog(
        mediaId: mediaId.value,
        mediaType: mediaType.value,
        mediaTitle: mediaItem.value?.title ?? '',
        onSubmit: (rating, content) => submitReview(rating, content),
      ),
    );
  }

  // Submit a new review
  Future<void> submitReview(double rating, String content) async {
    if (!_authService.isLoggedIn) {
      ToastUtil.showInfo('Please log in to review');
      return;
    }

    try {
      final user = _authService.currentUser!;

      // Check if user already reviewed this media
      final existingReview = reviews.firstWhereOrNull(
        (r) => r.userId == user.uid,
      );

      if (existingReview != null) {
        ToastUtil.showWarning('You have already reviewed this media');
        return;
      }

      // FIXED: Only use userId for the review initially, then fetch user details separately
      final reviewData = {
        'mediaId': mediaId.value,
        'mediaType': mediaType.value,
        'userId': user.uid,
        'rating': rating,
        'content': content,
        'likeCount': 0,
        'commentCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Add review to Firestore
      final reviewRef = await _firestore.collection('reviews').add(reviewData);
      print('Added new review with ID: ${reviewRef.id}');

      // Wait for server timestamp to be applied
      await Future.delayed(const Duration(milliseconds: 500));

      Map<String, dynamic> reviewWithTimestamp;

      try {
        final reviewDoc = await reviewRef.get();
        if (reviewDoc.exists) {
          reviewWithTimestamp = reviewDoc.data()! as Map<String, dynamic>;
        } else {
          reviewWithTimestamp = Map<String, dynamic>.from(reviewData);
          print(
            'Warning: Review document not found after creation, using local data',
          );
        }
      } catch (e) {
        // Fallback if we can't fetch the review
        reviewWithTimestamp = Map<String, dynamic>.from(reviewData);
        print('Error fetching new review: $e, using local data');
      }

      // Add timestamp information for local state if missing
      if (reviewWithTimestamp['createdAt'] == null) {
        reviewWithTimestamp['createdAt'] = Timestamp.now();
      }
      if (reviewWithTimestamp['updatedAt'] == null) {
        reviewWithTimestamp['updatedAt'] = Timestamp.now();
      }

      // Fetch user details
      final userDetails = await _getUserDetails(user.uid);
      reviewWithTimestamp['userFullName'] = userDetails['userFullName'];
      reviewWithTimestamp['userProfileImage'] = userDetails['userProfileImage'];

      // Create a Review object and add to local list
      final newReview = Review.fromMap(reviewWithTimestamp, reviewRef.id);
      reviews.insert(0, newReview);
      print('Added new review to local list');

      // Update the displayed reviews
      updateDisplayedReviews();

      // Update the media item's review count and average rating
      await _updateMediaRatings();

      ToastUtil.showSuccess('Review added successfully');
    } catch (e) {
      ToastUtil.showError('Error submitting review: $e');
      print('Error submitting review: $e');
    }
  }

  // Update the media item's review count and average rating
  Future<void> _updateMediaRatings() async {
    try {
      if (reviews.isEmpty) {
        print('No reviews available to calculate rating');
        return;
      }

      // Calculate new average rating
      double totalRating = 0;
      for (final review in reviews) {
        totalRating += review.rating;
      }
      final newAvgRating =
          reviews.isNotEmpty ? totalRating / reviews.length : 0;

      print(
        'Updating media ratings. Average: $newAvgRating, Count: ${reviews.length}',
      );

      // Update in Firestore
      await _firestore
          .collection('${mediaType.value}s')
          .doc(mediaId.value)
          .update({
            'averageRating': newAvgRating,
            'reviewCount': reviews.length,
            'updatedAt': FieldValue.serverTimestamp(),
          });

      // Update local media item based on type
      if (mediaItem.value != null) {
        // Create a copy of the current media item with updated rating
        switch (mediaType.value) {
          case 'movie':
            _updateMovieRating(newAvgRating.toDouble());
            break;
          case 'teledrama':
            _updateTeledramaRating(newAvgRating.toDouble());
            break;
          case 'song':
            _updateSongRating(newAvgRating.toDouble());
            break;
          case 'book':
            _updateBookRating(newAvgRating.toDouble());
            break;
        }
      }
    } catch (e) {
      print('Error updating media ratings: $e');
      ToastUtil.showError('Error updating ratings');
    }
  }

  // Helper methods to update media item with new rating
  void _updateMovieRating(double newAvgRating) {
    final movie = mediaItem.value as Movie;
    mediaItem.value = Movie(
      id: movie.id,
      title: movie.title,
      images: movie.images,
      description: movie.description,
      releaseDate: movie.releaseDate,
      genres: movie.genres,
      averageRating: newAvgRating,
      reviewCount: reviews.length,
      director: movie.director,
      cast: movie.cast,
      durationMinutes: movie.durationMinutes,
      createdAt: movie.createdAt,
      updatedAt: DateTime.now(),
    );
    print('Updated movie rating to: $newAvgRating');
  }

  void _updateTeledramaRating(double newAvgRating) {
    final teledrama = mediaItem.value as Teledrama;
    mediaItem.value = Teledrama(
      id: teledrama.id,
      title: teledrama.title,
      images: teledrama.images,
      description: teledrama.description,
      releaseDate: teledrama.releaseDate,
      genres: teledrama.genres,
      averageRating: newAvgRating,
      reviewCount: reviews.length,
      seasons: teledrama.seasons,
      episodes: teledrama.episodes,
      network: teledrama.network,
      cast: teledrama.cast,
      createdAt: teledrama.createdAt,
      updatedAt: DateTime.now(),
    );
    print('Updated teledrama rating to: $newAvgRating');
  }

  void _updateSongRating(double newAvgRating) {
    final song = mediaItem.value as Song;
    mediaItem.value = Song(
      id: song.id,
      title: song.title,
      images: song.images,
      description: song.description,
      releaseDate: song.releaseDate,
      genres: song.genres,
      averageRating: newAvgRating,
      reviewCount: reviews.length,
      artist: song.artist,
      album: song.album,
      durationSeconds: song.durationSeconds,
      featuring: song.featuring,
      createdAt: song.createdAt,
      updatedAt: DateTime.now(),
    );
    print('Updated song rating to: $newAvgRating');
  }

  void _updateBookRating(double newAvgRating) {
    final book = mediaItem.value as Book;
    mediaItem.value = Book(
      id: book.id,
      title: book.title,
      images: book.images,
      description: book.description,
      releaseDate: book.releaseDate,
      genres: book.genres,
      averageRating: newAvgRating,
      reviewCount: reviews.length,
      author: book.author,
      publisher: book.publisher,
      pages: book.pages,
      isbn: book.isbn,
      createdAt: book.createdAt,
      updatedAt: DateTime.now(),
    );
    print('Updated book rating to: $newAvgRating');
  }

  // Like a review
  Future<void> likeReview(String reviewId) async {
    if (!_authService.isLoggedIn) {
      ToastUtil.showInfo('Please log in to like');
      return;
    }

    try {
      final userId = _authService.currentUser!.uid;
      final likeRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('likedReviews')
          .doc(reviewId);

      // Get the review from Firestore to ensure we have the latest data
      final reviewDoc =
          await _firestore.collection('reviews').doc(reviewId).get();

      if (!reviewDoc.exists) {
        ToastUtil.showError('Review not found');
        return;
      }

      // Handle potentially missing fields in the document
      final reviewData = reviewDoc.data()! as Map<String, dynamic>;
      if (!reviewData.containsKey('likeCount') ||
          reviewData['likeCount'] == null) {
        reviewData['likeCount'] = 0;
      }

      final currentReview = Review.fromMap(reviewData, reviewId);
      final likeDoc = await likeRef.get();
      final isLiked = likeDoc.exists;
      final newLikeCount =
          isLiked ? currentReview.likeCount - 1 : currentReview.likeCount + 1;

      // Start a batch to ensure atomic operations
      final batch = _firestore.batch();

      if (isLiked) {
        // Unlike
        batch.delete(likeRef);
        userLikedReviews.remove(reviewId);
        print('User unliked review: $reviewId');
      } else {
        // Like
        batch.set(likeRef, {
          'reviewId': reviewId,
          'mediaId': mediaId.value,
          'createdAt': FieldValue.serverTimestamp(),
        });
        userLikedReviews.add(reviewId);
        print('User liked review: $reviewId');
      }

      // Update the review's like count
      batch.update(_firestore.collection('reviews').doc(reviewId), {
        'likeCount': newLikeCount,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Commit the batch
      await batch.commit();
      print('Updated review like count to: $newLikeCount');

      // Update local reviews list
      final reviewIndex = reviews.indexWhere((r) => r.id == reviewId);
      if (reviewIndex != -1) {
        final review = reviews[reviewIndex];
        final updatedReview = Review(
          id: review.id,
          mediaId: review.mediaId,
          mediaType: review.mediaType,
          userId: review.userId,
          userFullName: review.userFullName,
          userProfileImage: review.userProfileImage,
          rating: review.rating,
          content: review.content,
          likeCount: newLikeCount,
          commentCount: review.commentCount,
          createdAt: review.createdAt,
          updatedAt: review.updatedAt,
        );
        reviews[reviewIndex] = updatedReview;
      }

      // Update the displayed reviews since like counts may affect sorting
      updateDisplayedReviews();
    } catch (e) {
      ToastUtil.showError('Error liking review: $e');
      print('Error liking review: $e');
    }
  }

  // Like a comment
  Future<void> likeComment(String commentId) async {
    if (!_authService.isLoggedIn) {
      ToastUtil.showInfo('Please log in to like');
      return;
    }

    try {
      final userId = _authService.currentUser!.uid;
      final likeRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('likedComments')
          .doc(commentId);

      // Get the comment from Firestore to ensure we have the latest data
      final commentDoc =
          await _firestore.collection('comments').doc(commentId).get();

      if (!commentDoc.exists) {
        ToastUtil.showError('Comment not found');
        return;
      }

      // Handle potentially missing fields in the document
      final commentData = commentDoc.data()! as Map<String, dynamic>;
      if (!commentData.containsKey('likeCount') ||
          commentData['likeCount'] == null) {
        commentData['likeCount'] = 0;
      }

      final currentComment = Comment.fromMap(commentData, commentId);
      final likeDoc = await likeRef.get();
      final isLiked = likeDoc.exists;
      final newLikeCount =
          isLiked ? currentComment.likeCount - 1 : currentComment.likeCount + 1;

      // Start a batch to ensure atomic operations
      final batch = _firestore.batch();

      if (isLiked) {
        // Unlike
        batch.delete(likeRef);
        userLikedComments.remove(commentId);
        print('User unliked comment: $commentId');
      } else {
        // Like
        batch.set(likeRef, {
          'commentId': commentId,
          'reviewId': currentComment.reviewId,
          'createdAt': FieldValue.serverTimestamp(),
        });
        userLikedComments.add(commentId);
        print('User liked comment: $commentId');
      }

      // Update the comment's like count
      batch.update(_firestore.collection('comments').doc(commentId), {
        'likeCount': newLikeCount,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Commit the batch
      await batch.commit();
      print('Updated comment like count to: $newLikeCount');

      // Update local comments list
      final commentIndex = comments.indexWhere((c) => c.id == commentId);
      if (commentIndex != -1) {
        final comment = comments[commentIndex];
        final updatedComment = Comment(
          id: comment.id,
          parentId: comment.parentId,
          reviewId: comment.reviewId,
          userId: comment.userId,
          userFullName: comment.userFullName,
          userProfileImage: comment.userProfileImage,
          content: comment.content,
          likeCount: newLikeCount,
          replyCount: comment.replyCount,
          createdAt: comment.createdAt,
          updatedAt: comment.updatedAt,
        );
        comments[commentIndex] = updatedComment;
      }
    } catch (e) {
      ToastUtil.showError('Error liking comment: $e');
      print('Error liking comment: $e');
    }
  }

  // Toggle comments section for a review
  Future<void> toggleComments(String reviewId) async {
    if (expandedReviews.contains(reviewId)) {
      expandedReviews.remove(reviewId);
      print('Collapsed comments for review: $reviewId');
    } else {
      expandedReviews.add(reviewId);
      print('Expanded comments for review: $reviewId');
      await loadComments(reviewId);
    }
  }

  // Submit a new comment to a review
  Future<void> submitComment(String reviewId, String? parentId) async {
    if (!_authService.isLoggedIn) {
      ToastUtil.showInfo('Please log in to comment');
      return;
    }

    final textController =
        parentId == null ? getCommentController(reviewId) : replyController;
    final content = textController.text.trim();

    if (content.isEmpty) {
      ToastUtil.showWarning('Comment cannot be empty');
      return;
    }

    try {
      final user = _authService.currentUser!;

      // Prepare comment data with only user ID - we'll fetch user details separately
      final commentData = {
        'parentId': parentId,
        'reviewId': reviewId,
        'userId': user.uid,
        'content': content,
        'likeCount': 0,
        'replyCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Start a batch operation
      final batch = _firestore.batch();

      // Add comment to Firestore with a generated ID
      final commentRef = _firestore.collection('comments').doc();
      batch.set(commentRef, commentData);
      print(
        'Creating new comment with ID: ${commentRef.id} for review: $reviewId',
      );

      // Update review comment count
      final reviewRef = _firestore.collection('reviews').doc(reviewId);
      final reviewDoc = await reviewRef.get();

      if (!reviewDoc.exists) {
        ToastUtil.showError('Review not found');
        return;
      }

      // Check if the review has a commentCount field and provide a default if not
      final reviewData = reviewDoc.data()! as Map<String, dynamic>;
      int currentCommentCount = 0;

      if (reviewData.containsKey('commentCount') &&
          reviewData['commentCount'] != null) {
        currentCommentCount = reviewData['commentCount'];
      }

      batch.update(reviewRef, {
        'commentCount': currentCommentCount + 1,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // If this is a reply, update parent comment's reply count
      if (parentId != null) {
        final parentCommentRef = _firestore
            .collection('comments')
            .doc(parentId);
        final parentCommentDoc = await parentCommentRef.get();

        if (parentCommentDoc.exists) {
          // Check if the parent comment has a replyCount field and provide a default if not
          final parentData = parentCommentDoc.data()! as Map<String, dynamic>;
          int currentReplyCount = 0;

          if (parentData.containsKey('replyCount') &&
              parentData['replyCount'] != null) {
            currentReplyCount = parentData['replyCount'];
          }

          batch.update(parentCommentRef, {
            'replyCount': currentReplyCount + 1,
            'updatedAt': FieldValue.serverTimestamp(),
          });
          print('Updating parent comment reply count: $parentId');
        }
      }

      // Commit the batch
      await batch.commit();
      print('Comment batch committed successfully');

      // Wait for server timestamp to be applied (to make sure Firestore has time to process)
      await Future.delayed(const Duration(milliseconds: 500));

      // Fetch the comment with server timestamp
      Map<String, dynamic> commentWithTimestamp;

      try {
        final newCommentDoc = await commentRef.get();
        if (newCommentDoc.exists) {
          commentWithTimestamp = newCommentDoc.data()! as Map<String, dynamic>;
        } else {
          // If for some reason we can't fetch the comment, use our local data
          commentWithTimestamp = Map<String, dynamic>.from(commentData);
          print(
            'Warning: Comment document not found after creation, using local data',
          );
        }
      } catch (e) {
        // Fallback if we can't fetch the comment
        commentWithTimestamp = Map<String, dynamic>.from(commentData);
        print('Error fetching new comment: $e, using local data');
      }

      // Add timestamp information for local state if missing
      if (commentWithTimestamp['createdAt'] == null) {
        commentWithTimestamp['createdAt'] = Timestamp.now();
      }
      if (commentWithTimestamp['updatedAt'] == null) {
        commentWithTimestamp['updatedAt'] = Timestamp.now();
      }

      // Fetch user details to add to the comment
      final userDetails = await _getUserDetails(user.uid);
      commentWithTimestamp['userFullName'] = userDetails['userFullName'];
      commentWithTimestamp['userProfileImage'] =
          userDetails['userProfileImage'];

      // Create a Comment object and add to local list
      final newComment = Comment.fromMap(commentWithTimestamp, commentRef.id);
      comments.add(newComment);
      print('Added new comment to local list');

      // Clear the text controller
      textController.clear();
      if (parentId != null) {
        replyingToComment.value = null;
      }

      // Update local review's comment count
      final reviewIndex = reviews.indexWhere((r) => r.id == reviewId);
      if (reviewIndex != -1) {
        final review = reviews[reviewIndex];
        final updatedReview = Review(
          id: review.id,
          mediaId: review.mediaId,
          mediaType: review.mediaType,
          userId: review.userId,
          userFullName: review.userFullName,
          userProfileImage: review.userProfileImage,
          rating: review.rating,
          content: review.content,
          likeCount: review.likeCount,
          commentCount: review.commentCount + 1,
          createdAt: review.createdAt,
          updatedAt: DateTime.now(),
        );
        reviews[reviewIndex] = updatedReview;
        print('Updated review comment count to: ${updatedReview.commentCount}');

        // Update the displayed reviews to reflect the changes
        updateDisplayedReviews();
      }

      // If this is a reply, update parent comment's reply count locally
      if (parentId != null) {
        final parentCommentIndex = comments.indexWhere((c) => c.id == parentId);
        if (parentCommentIndex != -1) {
          final parentComment = comments[parentCommentIndex];
          final updatedParentComment = Comment(
            id: parentComment.id,
            parentId: parentComment.parentId,
            reviewId: parentComment.reviewId,
            userId: parentComment.userId,
            userFullName: parentComment.userFullName,
            userProfileImage: parentComment.userProfileImage,
            content: parentComment.content,
            likeCount: parentComment.likeCount,
            replyCount: parentComment.replyCount + 1,
            createdAt: parentComment.createdAt,
            updatedAt: DateTime.now(),
          );
          comments[parentCommentIndex] = updatedParentComment;
          print(
            'Updated parent comment reply count locally to: ${updatedParentComment.replyCount}',
          );
        }
      }

      ToastUtil.showSuccess('Comment added');
    } catch (e) {
      ToastUtil.showError('Error adding comment: $e');
      print('Error adding comment: $e');
    }
  }

  // Set up for replying to a comment
  void setReplyTo(Comment comment) {
    replyingToComment.value = comment;
    replyController.clear();
    print('Set up reply to comment: ${comment.id}');
  }

  // Cancel reply to comment
  void cancelReply() {
    replyingToComment.value = null;
    replyController.clear();
    print('Cancelled reply');
  }

  // Submit a reply to a comment
  Future<void> submitReply() async {
    if (replyingToComment.value == null) return;

    print('Submitting reply to comment: ${replyingToComment.value!.id}');
    await submitComment(
      replyingToComment.value!.reviewId,
      replyingToComment.value!.id,
    );
  }

  // Get comments for a specific review (excluding replies)
  List<Comment> getCommentsForReview(String reviewId) {
    // Make sure comments are loaded
    if (comments.isEmpty) {
      return [];
    }

    final result =
        comments
            .where((c) => c.reviewId == reviewId && c.parentId == null)
            .toList();

    // Sort by creation date
    if (result.isNotEmpty) {
      result.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    }

    print('Got ${result.length} top-level comments for review: $reviewId');
    return result;
  }

  // Get replies for a specific comment
  List<Comment> getRepliesForComment(String commentId) {
    // Make sure comments are loaded
    if (comments.isEmpty) {
      return [];
    }

    final result = comments.where((c) => c.parentId == commentId).toList();

    // Sort replies by creation date
    if (result.isNotEmpty) {
      result.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    }

    print('Got ${result.length} replies for comment: $commentId');
    return result;
  }

  // Delete a review
  Future<void> deleteReview(String reviewId) async {
    if (!_authService.isLoggedIn) {
      ToastUtil.showInfo('Please log in to delete reviews');
      return;
    }

    try {
      final review = reviews.firstWhereOrNull((r) => r.id == reviewId);
      if (review == null) {
        ToastUtil.showError('Review not found');
        return;
      }

      // Check if this is the user's review
      if (review.userId != _authService.currentUser!.uid) {
        ToastUtil.showError('You can only delete your own reviews');
        return;
      }

      // Confirm deletion
      final result = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Delete Review'),
          content: const Text(
            'Are you sure you want to delete this review? All comments will also be deleted.',
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        ),
      );

      if (result != true) return;

      print('Deleting review: $reviewId');

      try {
        // Delete the review and its comments using a transaction for atomicity
        await _firestore.runTransaction((transaction) async {
          // Get all comments for this review
          final commentsSnapshot =
              await _firestore
                  .collection('comments')
                  .where('reviewId', isEqualTo: reviewId)
                  .get();

          print(
            'Deleting ${commentsSnapshot.docs.length} comments for review: $reviewId',
          );

          // Delete all comments
          for (final doc in commentsSnapshot.docs) {
            transaction.delete(doc.reference);
          }

          // Delete the review
          transaction.delete(_firestore.collection('reviews').doc(reviewId));

          // Update media ratings
          final mediaRef = _firestore
              .collection('${mediaType.value}s')
              .doc(mediaId.value);
          final mediaDoc = await transaction.get(mediaRef);

          if (mediaDoc.exists) {
            // Calculate new average rating without the deleted review
            final remainingReviews =
                reviews.where((r) => r.id != reviewId).toList();
            double totalRating = 0;
            for (final r in remainingReviews) {
              totalRating += r.rating;
            }

            final newAvgRating =
                remainingReviews.isNotEmpty
                    ? totalRating / remainingReviews.length
                    : 0.0;

            // Update media with new rating
            transaction.update(mediaRef, {
              'averageRating': newAvgRating,
              'reviewCount': FieldValue.increment(-1),
              'updatedAt': FieldValue.serverTimestamp(),
            });

            print(
              'Updated media rating to: $newAvgRating after review deletion',
            );
          }
        });
      } catch (transactionError) {
        print('Transaction failed: $transactionError');

        // Fallback to batch operation if transaction fails
        print('Falling back to batch operation');
        final batch = _firestore.batch();

        // Delete the review
        batch.delete(_firestore.collection('reviews').doc(reviewId));

        // Get all comments for this review
        final commentsSnapshot =
            await _firestore
                .collection('comments')
                .where('reviewId', isEqualTo: reviewId)
                .get();

        // Delete all comments
        for (final doc in commentsSnapshot.docs) {
          batch.delete(doc.reference);
        }

        // Update media ratings
        final remainingReviews =
            reviews.where((r) => r.id != reviewId).toList();
        double totalRating = 0;
        for (final r in remainingReviews) {
          totalRating += r.rating;
        }

        final newAvgRating =
            remainingReviews.isNotEmpty
                ? totalRating / remainingReviews.length
                : 0.0;

        batch.update(
          _firestore.collection('${mediaType.value}s').doc(mediaId.value),
          {
            'averageRating': newAvgRating,
            'reviewCount': FieldValue.increment(-1),
            'updatedAt': FieldValue.serverTimestamp(),
          },
        );

        await batch.commit();
        print('Batch operation completed successfully');
      }

      // Update local lists
      reviews.removeWhere((r) => r.id == reviewId);
      comments.removeWhere((c) => c.reviewId == reviewId);
      updateDisplayedReviews();

      // Update local media item with new rating
      double totalRating = 0;
      for (final review in reviews) {
        totalRating += review.rating;
      }
      final newAvgRating =
          reviews.isNotEmpty ? totalRating / reviews.length : 0;

      switch (mediaType.value) {
        case 'movie':
          _updateMovieRating(newAvgRating.toDouble());
          break;
        case 'teledrama':
          _updateTeledramaRating(newAvgRating.toDouble());
          break;
        case 'song':
          _updateSongRating(newAvgRating.toDouble());
          break;
        case 'book':
          _updateBookRating(newAvgRating.toDouble());
          break;
      }

      ToastUtil.showSuccess('Review deleted successfully');
    } catch (e) {
      ToastUtil.showError('Error deleting review: $e');
      print('Error deleting review: $e');
    }
  }

  // Delete a comment
  Future<void> deleteComment(String commentId) async {
    if (!_authService.isLoggedIn) {
      ToastUtil.showInfo('Please log in to delete comments');
      return;
    }

    try {
      final comment = comments.firstWhereOrNull((c) => c.id == commentId);
      if (comment == null) {
        ToastUtil.showError('Comment not found');
        return;
      }

      // Check if this is the user's comment
      if (comment.userId != _authService.currentUser!.uid) {
        ToastUtil.showError('You can only delete your own comments');
        return;
      }

      // Confirm deletion
      final result = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Delete Comment'),
          content: const Text('Are you sure you want to delete this comment?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        ),
      );

      if (result != true) return;

      print('Deleting comment: $commentId');

      final batch = _firestore.batch();

      // Check if this is a parent comment with replies
      final replies = getRepliesForComment(commentId);

      if (replies.isNotEmpty) {
        // If it has replies, just update the content to indicate it was deleted
        batch.update(_firestore.collection('comments').doc(commentId), {
          'content': '[This comment was deleted]',
          'updatedAt': FieldValue.serverTimestamp(),
        });

        print(
          'Comment has ${replies.length} replies, marking as deleted instead of removing',
        );
      } else {
        // If no replies, delete the comment
        batch.delete(_firestore.collection('comments').doc(commentId));

        // If this is a reply, update parent comment's reply count
        if (comment.parentId != null) {
          final parentCommentRef = _firestore
              .collection('comments')
              .doc(comment.parentId);
          final parentCommentDoc = await parentCommentRef.get();

          if (parentCommentDoc.exists) {
            // Make sure we don't decrement below zero
            final parentData = parentCommentDoc.data()! as Map<String, dynamic>;
            int currentReplyCount = 0;

            if (parentData.containsKey('replyCount') &&
                parentData['replyCount'] != null) {
              currentReplyCount = parentData['replyCount'];
            }

            batch.update(parentCommentRef, {
              'replyCount':
                  currentReplyCount > 0 ? FieldValue.increment(-1) : 0,
              'updatedAt': FieldValue.serverTimestamp(),
            });

            print(
              'Decreasing reply count for parent comment: ${comment.parentId}',
            );
          }
        }
      }

      // Update review comment count
      final reviewRef = _firestore.collection('reviews').doc(comment.reviewId);
      final reviewDoc = await reviewRef.get();

      if (reviewDoc.exists) {
        // Make sure we don't decrement below zero
        final reviewData = reviewDoc.data()! as Map<String, dynamic>;
        int currentCommentCount = 0;

        if (reviewData.containsKey('commentCount') &&
            reviewData['commentCount'] != null) {
          currentCommentCount = reviewData['commentCount'];
        }

        batch.update(reviewRef, {
          'commentCount':
              currentCommentCount > 0 ? FieldValue.increment(-1) : 0,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        print('Decreasing comment count for review: ${comment.reviewId}');
      }

      await batch.commit();
      print('Comment batch committed successfully');

      // Update local lists
      if (replies.isEmpty) {
        comments.removeWhere((c) => c.id == commentId);

        // Update parent comment's reply count locally if this is a reply
        if (comment.parentId != null) {
          final parentIndex = comments.indexWhere(
            (c) => c.id == comment.parentId,
          );
          if (parentIndex != -1) {
            final parentComment = comments[parentIndex];
            final newReplyCount =
                parentComment.replyCount > 0 ? parentComment.replyCount - 1 : 0;

            comments[parentIndex] = Comment(
              id: parentComment.id,
              parentId: parentComment.parentId,
              reviewId: parentComment.reviewId,
              userId: parentComment.userId,
              userFullName: parentComment.userFullName,
              userProfileImage: parentComment.userProfileImage,
              content: parentComment.content,
              likeCount: parentComment.likeCount,
              replyCount: newReplyCount,
              createdAt: parentComment.createdAt,
              updatedAt: DateTime.now(),
            );

            print(
              'Updated parent comment reply count locally to: $newReplyCount',
            );
          }
        }
      } else {
        // Update the comment content locally
        final index = comments.indexWhere((c) => c.id == commentId);
        if (index != -1) {
          final c = comments[index];
          comments[index] = Comment(
            id: c.id,
            parentId: c.parentId,
            reviewId: c.reviewId,
            userId: c.userId,
            userFullName: c.userFullName,
            userProfileImage: c.userProfileImage,
            content: '[This comment was deleted]',
            likeCount: c.likeCount,
            replyCount: c.replyCount,
            createdAt: c.createdAt,
            updatedAt: DateTime.now(),
          );

          print('Marked comment as deleted in local state');
        }
      }

      // Update review comment count locally
      final reviewIndex = reviews.indexWhere((r) => r.id == comment.reviewId);
      if (reviewIndex != -1) {
        final review = reviews[reviewIndex];
        final newCommentCount =
            review.commentCount > 0 ? review.commentCount - 1 : 0;

        reviews[reviewIndex] = Review(
          id: review.id,
          mediaId: review.mediaId,
          mediaType: review.mediaType,
          userId: review.userId,
          userFullName: review.userFullName,
          userProfileImage: review.userProfileImage,
          rating: review.rating,
          content: review.content,
          likeCount: review.likeCount,
          commentCount: newCommentCount,
          createdAt: review.createdAt,
          updatedAt: DateTime.now(),
        );

        print('Updated review comment count locally to: $newCommentCount');
      }

      ToastUtil.showSuccess('Comment deleted successfully');
    } catch (e) {
      ToastUtil.showError('Error deleting comment: $e');
      print('Error deleting comment: $e');
    }
  }

  // Edit a review
  Future<void> editReview(
    String reviewId,
    double newRating,
    String newContent,
  ) async {
    if (!_authService.isLoggedIn) {
      ToastUtil.showInfo('Please log in to edit reviews');
      return;
    }

    try {
      final review = reviews.firstWhereOrNull((r) => r.id == reviewId);
      if (review == null) {
        ToastUtil.showError('Review not found');
        return;
      }

      // Check if this is the user's review
      if (review.userId != _authService.currentUser!.uid) {
        ToastUtil.showError('You can only edit your own reviews');
        return;
      }

      print('Editing review: $reviewId with rating: $newRating');

      // Update the review in Firestore
      await _firestore.collection('reviews').doc(reviewId).update({
        'rating': newRating,
        'content': newContent,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update the review locally
      final reviewIndex = reviews.indexWhere((r) => r.id == reviewId);
      if (reviewIndex != -1) {
        final oldRating = reviews[reviewIndex].rating;
        reviews[reviewIndex] = Review(
          id: review.id,
          mediaId: review.mediaId,
          mediaType: review.mediaType,
          userId: review.userId,
          userFullName: review.userFullName,
          userProfileImage: review.userProfileImage,
          rating: newRating,
          content: newContent,
          likeCount: review.likeCount,
          commentCount: review.commentCount,
          createdAt: review.createdAt,
          updatedAt: DateTime.now(),
        );

        print('Updated review locally');

        // Update displayed reviews
        updateDisplayedReviews();

        // Update media average rating if the rating changed
        if (oldRating != newRating) {
          await _updateMediaRatings();
        }
      }

      ToastUtil.showSuccess('Review updated successfully');
    } catch (e) {
      ToastUtil.showError('Error updating review: $e');
      print('Error updating review: $e');
    }
  }

  // Show dialog to edit a review
  void showEditReviewDialog(String reviewId) {
    final review = reviews.firstWhereOrNull((r) => r.id == reviewId);
    if (review == null) {
      ToastUtil.showError('Review not found');
      return;
    }

    if (review.userId != _authService.currentUser?.uid) {
      ToastUtil.showError('You can only edit your own reviews');
      return;
    }

    print('Showing edit dialog for review: $reviewId');

    Get.dialog(
      ReviewDialog(
        mediaId: mediaId.value,
        mediaType: mediaType.value,
        mediaTitle: mediaItem.value?.title ?? '',
        initialRating: review.rating,
        initialContent: review.content,
        isEdit: true,
        onSubmit: (rating, content) => editReview(reviewId, rating, content),
      ),
    );
  }

  // Check if user has already reviewed this media
  bool hasUserReviewed() {
    if (!_authService.isLoggedIn) return false;

    final userId = _authService.currentUser!.uid;
    return reviews.any((r) => r.userId == userId);
  }

  // Get the current user's review if exists
  Review? getUserReview() {
    if (!_authService.isLoggedIn) return null;

    final userId = _authService.currentUser!.uid;
    return reviews.firstWhereOrNull((r) => r.userId == userId);
  }
}
