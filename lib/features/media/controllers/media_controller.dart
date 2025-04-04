import 'package:get/get.dart';
import '../../../core/services/firebase_service.dart';
import '../../media/models/movie.dart';
import '../../media/models/teledrama.dart';
import '../../media/models/song.dart';
import '../../media/models/book.dart';

class MediaController extends GetxController {
  final FirebaseService _firebaseService = Get.find<FirebaseService>();

  // Media type selection (for filtering)
  final selectedMediaType = 'All'.obs;
  final mediaTypes = ['All', 'Movies', 'TV Shows', 'Songs', 'Books'];

  // Combined list of all media items
  final allMedia = <dynamic>[].obs;

  // Separate lists for each media type
  final movies = <Movie>[].obs;
  final teledramas = <Teledrama>[].obs;
  final songs = <Song>[].obs;
  final books = <Book>[].obs;

  // Loading states
  final isLoading = true.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  // Search query
  final searchQuery = ''.obs;

  // Pagination
  final currentPage = 1.obs;
  final itemsPerPage = 10;
  final totalPages = 1.obs;

  // Filtered and paginated data for display
  List<dynamic> get displayedMedia {
    // First, apply media type filter
    List<dynamic> filtered = [];

    if (selectedMediaType.value == 'All') {
      filtered = allMedia;
    } else if (selectedMediaType.value == 'Movies') {
      filtered = movies;
    } else if (selectedMediaType.value == 'TV Shows') {
      filtered = teledramas;
    } else if (selectedMediaType.value == 'Songs') {
      filtered = songs;
    } else if (selectedMediaType.value == 'Books') {
      filtered = books;
    }

    // Then apply search filter if there's a search query
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filtered =
          filtered.where((item) {
            final title = getTitleFromItem(item).toLowerCase();
            return title.contains(query);
          }).toList();
    }

    // Update total pages count
    totalPages.value = (filtered.length / itemsPerPage).ceil();
    if (totalPages.value < 1) totalPages.value = 1;

    // Apply pagination
    final startIndex = (currentPage.value - 1) * itemsPerPage;
    final endIndex = startIndex + itemsPerPage;

    if (startIndex >= filtered.length) {
      // If current page is beyond available data, reset to page 1
      currentPage.value = 1;
      return filtered.isEmpty
          ? []
          : filtered.sublist(
            0,
            filtered.length < itemsPerPage ? filtered.length : itemsPerPage,
          );
    }

    return filtered.sublist(
      startIndex,
      endIndex > filtered.length ? filtered.length : endIndex,
    );
  }

  @override
  void onInit() {
    super.onInit();
    loadAllMedia();
  }

  // Function to handle media type filter change
  void changeMediaType(String type) {
    selectedMediaType.value = type;
    currentPage.value = 1; // Reset to first page when filter changes
  }

  // Function to handle search query change
  void updateSearchQuery(String query) {
    searchQuery.value = query;
    currentPage.value = 1; // Reset to first page when search changes
  }

  // Function to load all media from Firestore
  Future<void> loadAllMedia() async {
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      // Load all media types in parallel
      await Future.wait([
        _loadMovies(),
        _loadTeledramas(),
        _loadSongs(),
        _loadBooks(),
      ]);

      // Combine all media into one list
      allMedia.value = [...movies, ...teledramas, ...songs, ...books];

      // Sort combined list by rating (descending)
      allMedia.sort((a, b) {
        final ratingA = getRatingFromItem(a);
        final ratingB = getRatingFromItem(b);
        return ratingB.compareTo(ratingA);
      });
    } catch (e) {
      print('Error loading media: $e');
      hasError.value = true;
      errorMessage.value = 'Failed to load media: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  // Load movies from Firestore
  Future<void> _loadMovies() async {
    try {
      final snapshot =
          await _firebaseService.moviesCollection
              .orderBy('averageRating', descending: true)
              .get();

      final loadedMovies =
          snapshot.docs.map((doc) {
            return Movie.fromMap(doc.data() as Map<String, dynamic>, doc.id);
          }).toList();

      movies.value = loadedMovies;
    } catch (e) {
      print('Error loading movies: $e');
      throw Exception('Failed to load movies: ${e.toString()}');
    }
  }

  // Load TV shows from Firestore
  Future<void> _loadTeledramas() async {
    try {
      final snapshot =
          await _firebaseService.teledramasCollection
              .orderBy('averageRating', descending: true)
              .get();

      final loadedTeledramas =
          snapshot.docs.map((doc) {
            return Teledrama.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            );
          }).toList();

      teledramas.value = loadedTeledramas;
    } catch (e) {
      print('Error loading TV shows: $e');
      throw Exception('Failed to load TV shows: ${e.toString()}');
    }
  }

  // Load songs from Firestore
  Future<void> _loadSongs() async {
    try {
      final snapshot =
          await _firebaseService.songsCollection
              .orderBy('averageRating', descending: true)
              .get();

      final loadedSongs =
          snapshot.docs.map((doc) {
            return Song.fromMap(doc.data() as Map<String, dynamic>, doc.id);
          }).toList();

      songs.value = loadedSongs;
    } catch (e) {
      print('Error loading songs: $e');
      throw Exception('Failed to load songs: ${e.toString()}');
    }
  }

  // Load books from Firestore
  Future<void> _loadBooks() async {
    try {
      final snapshot =
          await _firebaseService.booksCollection
              .orderBy('averageRating', descending: true)
              .get();

      final loadedBooks =
          snapshot.docs.map((doc) {
            return Book.fromMap(doc.data() as Map<String, dynamic>, doc.id);
          }).toList();

      books.value = loadedBooks;
    } catch (e) {
      print('Error loading books: $e');
      throw Exception('Failed to load books: ${e.toString()}');
    }
  }

  // Helper function to extract title from any media item
  String getTitleFromItem(dynamic item) {
    if (item is Movie) return item.title;
    if (item is Teledrama) return item.title;
    if (item is Song) return item.title;
    if (item is Book) return item.title;
    return '';
  }

  // Helper function to extract rating from any media item
  double getRatingFromItem(dynamic item) {
    if (item is Movie) return item.averageRating;
    if (item is Teledrama) return item.averageRating;
    if (item is Song) return item.averageRating;
    if (item is Book) return item.averageRating;
    return 0.0;
  }

  // Helper function to extract type from any media item
  String getMediaTypeFromItem(dynamic item) {
    if (item is Movie) return 'movie';
    if (item is Teledrama) return 'teledrama';
    if (item is Song) return 'song';
    if (item is Book) return 'book';
    return '';
  }

  // Helper function to extract subtitle from any media item
  String getSubtitleFromItem(dynamic item) {
    if (item is Movie) return item.director;
    if (item is Teledrama) return item.network;
    if (item is Song) return item.artist;
    if (item is Book) return 'by ${item.author}';
    return '';
  }

  // Helper function to extract image from any media item
  String getImageFromItem(dynamic item) {
    if (item is Movie) {
      return item.images.isNotEmpty ? item.images.first : '';
    }
    if (item is Teledrama) {
      return item.images.isNotEmpty ? item.images.first : '';
    }
    if (item is Song) {
      return item.images.isNotEmpty ? item.images.first : '';
    }
    if (item is Book) {
      return item.images.isNotEmpty ? item.images.first : '';
    }
    return '';
  }

  // Helper function to extract genres from any media item
  List<String> getGenresFromItem(dynamic item) {
    if (item is Movie) return item.genres;
    if (item is Teledrama) return item.genres;
    if (item is Song) return item.genres;
    if (item is Book) return item.genres;
    return [];
  }

  // Pagination controls
  void nextPage() {
    if (currentPage.value < totalPages.value) {
      currentPage.value++;
    }
  }

  void previousPage() {
    if (currentPage.value > 1) {
      currentPage.value--;
    }
  }

  void goToPage(int page) {
    if (page >= 1 && page <= totalPages.value) {
      currentPage.value = page;
    }
  }

  // Retry loading in case of error
  Future<void> retryLoading() async {
    hasError.value = false;
    errorMessage.value = '';
    await loadAllMedia();
  }
}
