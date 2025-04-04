import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import '../../../core/services/auth_service.dart';
import '../../../core/services/firebase_service.dart';
import '../../auth/models/user_profile.dart';
import '../../media/models/movie.dart';
import '../../media/models/teledrama.dart';
import '../../media/models/song.dart';
import '../../media/models/book.dart';

class HomeController extends GetxController {
  final FirebaseService _firebaseService = Get.find<FirebaseService>();
  final AuthService _authService = Get.find<AuthService>();
  final RxBool isLoggedIn = false.obs;
  final Rx<UserProfile> userProfile =
      UserProfile(
        id: '',
        fullName: '',
        email: '',
        mobile: '',
        profileImage: null,
      ).obs;
  // User data
  final isUserLoggedIn = false.obs;

  // Media lists
  final topMovies = <Movie>[].obs;
  final topTeledramas = <Teledrama>[].obs;
  final topSongs = <Song>[].obs;
  final topBooks = <Book>[].obs;

  // Loading states
  final isLoadingMovies = true.obs;
  final isLoadingTeledramas = true.obs;
  final isLoadingSongs = true.obs;
  final isLoadingBooks = true.obs;

  // Controllers for UI
  late final PageController moviePageController;
  late final ScrollController songsScrollController;

  // State variables
  final currentMovieIndex = 0.obs;
  Timer? _autoScrollTimer;

  // Added flag to prevent multiple initializations of auto-scroll
  // This helps avoid Widget binding issues that can cause GlobalKey conflicts
  bool isAutoScrollInitialized = false;

  @override
  void onInit() {
    super.onInit();

    // Initialize controllers
    // Using unique keys for controllers to avoid GlobalKey conflicts
    moviePageController = PageController(initialPage: 0);
    songsScrollController = ScrollController();

    // Check if user is logged in
    isUserLoggedIn.value = _authService.isLoggedIn;
    if (isUserLoggedIn.value) {
      _loadUserProfile();
    }

    // Load media data
    loadAllData();
  }

  @override
  void onClose() {
    // Proper resource cleanup to avoid memory leaks
    moviePageController.dispose();
    songsScrollController.dispose();

    // Cancel auto scroll timer
    if (_autoScrollTimer != null) {
      _autoScrollTimer!.cancel();
      _autoScrollTimer = null; // Set to null to avoid potential issues
    }

    super.onClose();
  }

  Future<void> loadAllData() async {
    // Load all data in parallel for efficiency
    await Future.wait([
      _loadTopMovies(),
      _loadTopTeledramas(),
      _loadTopSongs(),
      _loadTopBooks(),
    ]);
    return Future.value(); // Explicit return for the RefreshIndicator
  }

  Future<void> _loadUserProfile() async {
    try {
      final profile = await _authService.getCurrentUserProfile();
      if (profile != null) {
        userProfile.value = profile;
      }
    } catch (e) {
      print('Error loading user profile: $e');
      // Consider using a snackbar or other UI feedback for user
    }
  }

  Future<void> _loadTopMovies() async {
    isLoadingMovies.value = true;
    try {
      final snapshot =
          await _firebaseService.moviesCollection
              .orderBy('averageRating', descending: true)
              .limit(5)
              .get();

      final movies =
          snapshot.docs.map((doc) {
            return Movie.fromMap(doc.data() as Map<String, dynamic>, doc.id);
          }).toList();

      topMovies.value = movies;
    } catch (e) {
      print('Error loading top movies: $e');
      // Fall back to dummy data for preview or development
      _addDummyMovies();
    } finally {
      isLoadingMovies.value = false;
    }
  }

  Future<void> _loadTopTeledramas() async {
    isLoadingTeledramas.value = true;
    try {
      final snapshot =
          await _firebaseService.teledramasCollection
              .orderBy('averageRating', descending: true)
              .limit(4)
              .get();

      final teledramas =
          snapshot.docs.map((doc) {
            return Teledrama.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            );
          }).toList();

      topTeledramas.value = teledramas;
    } catch (e) {
      print('Error loading top teledramas: $e');
      _addDummyTeledramas();
    } finally {
      isLoadingTeledramas.value = false;
    }
  }

  Future<void> _loadTopSongs() async {
    isLoadingSongs.value = true;
    try {
      final snapshot =
          await _firebaseService.songsCollection
              .orderBy('averageRating', descending: true)
              .limit(10)
              .get();

      final songs =
          snapshot.docs.map((doc) {
            return Song.fromMap(doc.data() as Map<String, dynamic>, doc.id);
          }).toList();

      topSongs.value = songs;
    } catch (e) {
      print('Error loading top songs: $e');
      _addDummySongs();
    } finally {
      isLoadingSongs.value = false;
    }
  }

  Future<void> _loadTopBooks() async {
    isLoadingBooks.value = true;
    try {
      final snapshot =
          await _firebaseService.booksCollection
              .orderBy('averageRating', descending: true)
              .limit(4)
              .get();

      final books =
          snapshot.docs.map((doc) {
            return Book.fromMap(doc.data() as Map<String, dynamic>, doc.id);
          }).toList();

      topBooks.value = books;
    } catch (e) {
      print('Error loading top books: $e');
      _addDummyBooks();
    } finally {
      isLoadingBooks.value = false;
    }
  }

  // Auto-scroll for songs list
  // Modified to check the isAutoScrollInitialized flag to prevent multiple timers
  void startSongsAutoScroll() {
    // Skip if already initialized to prevent duplicate timers
    if (isAutoScrollInitialized) return;
    isAutoScrollInitialized = true;

    // Cancel any existing timer as a safety measure
    _autoScrollTimer?.cancel();

    // Start a new timer for auto-scrolling
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (songsScrollController.hasClients) {
        final currentPosition = songsScrollController.offset;
        final maxScrollExtent = songsScrollController.position.maxScrollExtent;

        if (currentPosition < maxScrollExtent) {
          songsScrollController.animateTo(
            currentPosition + 160, // Width of one song card
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        } else {
          // Reset to beginning when reaching the end
          songsScrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
          );
        }
      }
    });
  }

  // Add dummy data methods for preview/testing
  void _addDummyMovies() {
    final now = DateTime.now();

    topMovies.value = [
      Movie(
        id: '1',
        title: 'Inception',
        images: ['https://via.placeholder.com/400x600?text=Inception'],
        description:
            'A thief who steals corporate secrets through the use of dream-sharing technology.',
        releaseDate: DateTime(2010, 7, 16),
        genres: ['Sci-Fi', 'Action', 'Thriller'],
        averageRating: 4.8,
        reviewCount: 1254,
        director: 'Christopher Nolan',
        cast: ['Leonardo DiCaprio', 'Joseph Gordon-Levitt', 'Ellen Page'],
        durationMinutes: 148,
        createdAt: now,
        updatedAt: now,
      ),
      Movie(
        id: '2',
        title: 'The Shawshank Redemption',
        images: ['https://via.placeholder.com/400x600?text=Shawshank'],
        description:
            'Two imprisoned men bond over a number of years, finding solace and redemption through acts of common decency.',
        releaseDate: DateTime(1994, 9, 22),
        genres: ['Drama', 'Crime'],
        averageRating: 4.9,
        reviewCount: 2548,
        director: 'Frank Darabont',
        cast: ['Tim Robbins', 'Morgan Freeman', 'Bob Gunton'],
        durationMinutes: 142,
        createdAt: now,
        updatedAt: now,
      ),
      Movie(
        id: '3',
        title: 'Pulp Fiction',
        images: ['https://via.placeholder.com/400x600?text=PulpFiction'],
        description:
            'The lives of two mob hitmen, a boxer, a gangster and his wife intertwine in four tales of violence and redemption.',
        releaseDate: DateTime(1994, 10, 14),
        genres: ['Crime', 'Drama'],
        averageRating: 4.7,
        reviewCount: 1876,
        director: 'Quentin Tarantino',
        cast: ['John Travolta', 'Uma Thurman', 'Samuel L. Jackson'],
        durationMinutes: 154,
        createdAt: now,
        updatedAt: now,
      ),
      Movie(
        id: '4',
        title: 'The Dark Knight',
        images: ['https://via.placeholder.com/400x600?text=DarkKnight'],
        description:
            'When the menace known as the Joker wreaks havoc on Gotham City, Batman must accept one of the greatest tests of his ability to fight injustice.',
        releaseDate: DateTime(2008, 7, 18),
        genres: ['Action', 'Crime', 'Drama'],
        averageRating: 4.9,
        reviewCount: 2354,
        director: 'Christopher Nolan',
        cast: ['Christian Bale', 'Heath Ledger', 'Aaron Eckhart'],
        durationMinutes: 152,
        createdAt: now,
        updatedAt: now,
      ),
      Movie(
        id: '5',
        title: 'The Godfather',
        images: ['https://via.placeholder.com/400x600?text=Godfather'],
        description:
            'The aging patriarch of an organized crime dynasty transfers control to his reluctant son.',
        releaseDate: DateTime(1972, 3, 24),
        genres: ['Crime', 'Drama'],
        averageRating: 4.9,
        reviewCount: 1725,
        director: 'Francis Ford Coppola',
        cast: ['Marlon Brando', 'Al Pacino', 'James Caan'],
        durationMinutes: 175,
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }

  void _addDummyTeledramas() {
    final now = DateTime.now();

    topTeledramas.value = [
      Teledrama(
        id: '1',
        title: 'Breaking Bad',
        images: ['https://via.placeholder.com/300x450?text=BreakingBad'],
        description:
            'A high school chemistry teacher turned methamphetamine manufacturer.',
        releaseDate: DateTime(2008, 1, 20),
        genres: ['Crime', 'Drama', 'Thriller'],
        averageRating: 4.9,
        reviewCount: 1845,
        seasons: 5,
        episodes: 62,
        network: 'AMC',
        cast: ['Bryan Cranston', 'Aaron Paul', 'Anna Gunn'],
        createdAt: now,
        updatedAt: now,
      ),
      Teledrama(
        id: '2',
        title: 'Game of Thrones',
        images: ['https://via.placeholder.com/300x450?text=GameOfThrones'],
        description:
            'Nine noble families fight for control over the lands of Westeros.',
        releaseDate: DateTime(2011, 4, 17),
        genres: ['Action', 'Adventure', 'Drama'],
        averageRating: 4.7,
        reviewCount: 2367,
        seasons: 8,
        episodes: 73,
        network: 'HBO',
        cast: ['Emilia Clarke', 'Kit Harington', 'Peter Dinklage'],
        createdAt: now,
        updatedAt: now,
      ),
      Teledrama(
        id: '3',
        title: 'Stranger Things',
        images: ['https://via.placeholder.com/300x450?text=StrangerThings'],
        description:
            'When a young boy disappears, his friends, family, and police are drawn into a mystery.',
        releaseDate: DateTime(2016, 7, 15),
        genres: ['Drama', 'Fantasy', 'Horror'],
        averageRating: 4.8,
        reviewCount: 1967,
        seasons: 4,
        episodes: 34,
        network: 'Netflix',
        cast: ['Millie Bobby Brown', 'Finn Wolfhard', 'Winona Ryder'],
        createdAt: now,
        updatedAt: now,
      ),
      Teledrama(
        id: '4',
        title: 'The Crown',
        images: ['https://via.placeholder.com/300x450?text=TheCrown'],
        description:
            'Follows the political rivalries and romance of Queen Elizabeth II\'s reign.',
        releaseDate: DateTime(2016, 11, 4),
        genres: ['Biography', 'Drama', 'History'],
        averageRating: 4.7,
        reviewCount: 1254,
        seasons: 5,
        episodes: 50,
        network: 'Netflix',
        cast: ['Claire Foy', 'Olivia Colman', 'Imelda Staunton'],
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }

  void _addDummySongs() {
    final now = DateTime.now();

    topSongs.value = [
      Song(
        id: '1',
        title: 'Bohemian Rhapsody',
        images: ['https://via.placeholder.com/300x300?text=BohemianRhapsody'],
        description:
            'A six-minute suite, consisting of several sections without a chorus.',
        releaseDate: DateTime(1975, 10, 31),
        genres: ['Rock', 'Progressive Rock'],
        averageRating: 4.9,
        reviewCount: 3254,
        artist: 'Queen',
        album: 'A Night at the Opera',
        durationSeconds: 354,
        featuring: [],
        createdAt: now,
        updatedAt: now,
      ),
      Song(
        id: '2',
        title: 'Imagine',
        images: ['https://via.placeholder.com/300x300?text=Imagine'],
        description:
            'A song encouraging listeners to imagine a world of peace.',
        releaseDate: DateTime(1971, 10, 11),
        genres: ['Soft Rock', 'Piano Rock'],
        averageRating: 4.8,
        reviewCount: 2187,
        artist: 'John Lennon',
        album: 'Imagine',
        durationSeconds: 183,
        featuring: [],
        createdAt: now,
        updatedAt: now,
      ),
      Song(
        id: '3',
        title: 'Billie Jean',
        images: ['https://via.placeholder.com/300x300?text=BillieJean'],
        description:
            'A song about a woman who claims the narrator is the father of her child.',
        releaseDate: DateTime(1983, 1, 2),
        genres: ['Pop', 'R&B', 'Dance'],
        averageRating: 4.9,
        reviewCount: 2876,
        artist: 'Michael Jackson',
        album: 'Thriller',
        durationSeconds: 293,
        featuring: [],
        createdAt: now,
        updatedAt: now,
      ),
      Song(
        id: '4',
        title: 'Like a Rolling Stone',
        images: ['https://via.placeholder.com/300x300?text=RollingStone'],
        description:
            'A confrontational song addressing a woman who has fallen from grace.',
        releaseDate: DateTime(1965, 7, 20),
        genres: ['Rock', 'Folk Rock'],
        averageRating: 4.7,
        reviewCount: 1547,
        artist: 'Bob Dylan',
        album: 'Highway 61 Revisited',
        durationSeconds: 373,
        featuring: [],
        createdAt: now,
        updatedAt: now,
      ),
      Song(
        id: '5',
        title: 'Smells Like Teen Spirit',
        images: ['https://via.placeholder.com/300x300?text=TeenSpirit'],
        description: 'An anthem for apathetic kids of Generation X.',
        releaseDate: DateTime(1991, 9, 10),
        genres: ['Grunge', 'Alternative Rock'],
        averageRating: 4.8,
        reviewCount: 2367,
        artist: 'Nirvana',
        album: 'Nevermind',
        durationSeconds: 301,
        featuring: [],
        createdAt: now,
        updatedAt: now,
      ),
      Song(
        id: '6',
        title: 'Hotel California',
        images: ['https://via.placeholder.com/300x300?text=HotelCalifornia'],
        description:
            'A song about the excesses of American culture and the dark underside of the Hollywood scene.',
        releaseDate: DateTime(1977, 2, 22),
        genres: ['Rock', 'Soft Rock'],
        averageRating: 4.9,
        reviewCount: 2145,
        artist: 'Eagles',
        album: 'Hotel California',
        durationSeconds: 391,
        featuring: [],
        createdAt: now,
        updatedAt: now,
      ),
      Song(
        id: '7',
        title: 'Sweet Child O\' Mine',
        images: ['https://via.placeholder.com/300x300?text=SweetChild'],
        description: 'A song written for Axl Rose\'s then-girlfriend.',
        releaseDate: DateTime(1988, 6, 15),
        genres: ['Hard Rock', 'Heavy Metal'],
        averageRating: 4.8,
        reviewCount: 1985,
        artist: 'Guns N\' Roses',
        album: 'Appetite for Destruction',
        durationSeconds: 356,
        featuring: [],
        createdAt: now,
        updatedAt: now,
      ),
      Song(
        id: '8',
        title: 'Stairway to Heaven',
        images: ['https://via.placeholder.com/300x300?text=StairwayToHeaven'],
        description:
            'A song about a woman who accumulates money but finds out that her life has no meaning.',
        releaseDate: DateTime(1971, 11, 8),
        genres: ['Rock', 'Folk Rock', 'Hard Rock'],
        averageRating: 4.9,
        reviewCount: 2654,
        artist: 'Led Zeppelin',
        album: 'Led Zeppelin IV',
        durationSeconds: 482,
        featuring: [],
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }

  void _addDummyBooks() {
    final now = DateTime.now();

    topBooks.value = [
      Book(
        id: '1',
        title: 'To Kill a Mockingbird',
        images: ['https://via.placeholder.com/300x450?text=ToKillAMockingbird'],
        description:
            'The story of a young girl confronting the harsh realities of racial inequality in her hometown.',
        releaseDate: DateTime(1960, 7, 11),
        genres: ['Classic', 'Fiction'],
        averageRating: 4.8,
        reviewCount: 2456,
        author: 'Harper Lee',
        publisher: 'J. B. Lippincott & Co.',
        pages: 281,
        isbn: '978-0-06-112008-4',
        createdAt: now,
        updatedAt: now,
      ),
      Book(
        id: '2',
        title: '1984',
        images: ['https://via.placeholder.com/300x450?text=1984'],
        description:
            'A dystopian novel set in a totalitarian society where individualism and independent thinking are persecuted.',
        releaseDate: DateTime(1949, 6, 8),
        genres: ['Dystopian', 'Political Fiction'],
        averageRating: 4.7,
        reviewCount: 1987,
        author: 'George Orwell',
        publisher: 'Secker & Warburg',
        pages: 328,
        isbn: '978-0-452-28423-4',
        createdAt: now,
        updatedAt: now,
      ),
      Book(
        id: '3',
        title: 'The Great Gatsby',
        images: ['https://via.placeholder.com/300x450?text=GreatGatsby'],
        description:
            'A tragedy set in the roaring twenties that examines the hollowness of the American Dream.',
        releaseDate: DateTime(1925, 4, 10),
        genres: ['Classic', 'Fiction'],
        averageRating: 4.5,
        reviewCount: 1654,
        author: 'F. Scott Fitzgerald',
        publisher: 'Charles Scribner\'s Sons',
        pages: 180,
        isbn: '978-0-7432-7356-5',
        createdAt: now,
        updatedAt: now,
      ),
      Book(
        id: '4',
        title: 'Harry Potter and the Philosopher\'s Stone',
        images: ['https://via.placeholder.com/300x450?text=HarryPotter'],
        description:
            'The first novel in the Harry Potter series and follows young wizard Harry Potter\'s first year at Hogwarts School.',
        releaseDate: DateTime(1997, 6, 26),
        genres: ['Fantasy', 'Young Adult'],
        averageRating: 4.9,
        reviewCount: 3254,
        author: 'J.K. Rowling',
        publisher: 'Bloomsbury',
        pages: 223,
        isbn: '978-0-7475-3269-9',
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }
}

// // lib/features/testing/controllers/dummy_data_controller.dart
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'dart:async';
// import '../../../features/auth/models/user_profile.dart';
// import '../../../features/media/models/movie.dart';
// import '../../../features/media/models/teledrama.dart';
// import '../../../features/media/models/song.dart';
// import '../../../features/media/models/book.dart';

// /// A testing controller that provides dummy data for UI development
// /// without requiring Firebase connection
// class DummyDataController extends GetxController {
//   // User data
//   final isUserLoggedIn = true.obs; // Set to true for testing with logged-in UI
//   final userProfile = Rx<UserProfile?>(null);

//   // Media lists
//   final topMovies = <Movie>[].obs;
//   final topTeledramas = <Teledrama>[].obs;
//   final topSongs = <Song>[].obs;
//   final topBooks = <Book>[].obs;

//   // Loading states - initially true, then set to false when data is loaded
//   final isLoadingMovies = true.obs;
//   final isLoadingTeledramas = true.obs;
//   final isLoadingSongs = true.obs;
//   final isLoadingBooks = true.obs;

//   // Controllers for UI
//   late final PageController moviePageController;
//   late final ScrollController songsScrollController;

//   // State variables
//   final currentMovieIndex = 0.obs;
//   Timer? _autoScrollTimer;
//   bool isAutoScrollInitialized = false;

//   @override
//   void onInit() {
//     super.onInit();

//     // Initialize controllers with unique instances
//     moviePageController = PageController(initialPage: 0);
//     songsScrollController = ScrollController();

//     // Load mock user profile
//     _createMockUserProfile();

//     // Load all dummy data
//     loadAllData();
//   }

//   @override
//   void onClose() {
//     // Clean up resources
//     moviePageController.dispose();
//     songsScrollController.dispose();

//     if (_autoScrollTimer != null) {
//       _autoScrollTimer!.cancel();
//       _autoScrollTimer = null;
//     }

//     super.onClose();
//   }

//   Future<void> loadAllData() async {
//     // Simulate network delay
//     await Future.delayed(const Duration(milliseconds: 800));

//     // Load all mock data
//     _addDummyMovies();
//     _addDummyTeledramas();
//     _addDummySongs();
//     _addDummyBooks();

//     // Set loading states to false
//     isLoadingMovies.value = false;
//     isLoadingTeledramas.value = false;
//     isLoadingSongs.value = false;
//     isLoadingBooks.value = false;

//     return Future.value(); // For RefreshIndicator
//   }

//   void _createMockUserProfile() {
//     userProfile.value = UserProfile(
//       id: 'test-user-123',
//       fullName: 'John Doe',
//       email: 'john.doe@example.com',
//       mobile: '+1234567890',
//       profileImage: 'https://via.placeholder.com/150?text=John',
//       createdAt: DateTime.now().subtract(const Duration(days: 30)),
//       updatedAt: DateTime.now(),
//     );
//   }

//   // Auto-scroll for songs list
//   void startSongsAutoScroll() {
//     // Skip if already initialized
//     if (isAutoScrollInitialized) return;
//     isAutoScrollInitialized = true;

//     // Cancel any existing timer
//     _autoScrollTimer?.cancel();

//     // Start a new timer for auto-scrolling
//     _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
//       if (songsScrollController.hasClients) {
//         final currentPosition = songsScrollController.offset;
//         final maxScrollExtent = songsScrollController.position.maxScrollExtent;

//         if (currentPosition < maxScrollExtent) {
//           songsScrollController.animateTo(
//             currentPosition + 160, // Width of one song card
//             duration: const Duration(milliseconds: 500),
//             curve: Curves.easeInOut,
//           );
//         } else {
//           // Reset to beginning when reaching the end
//           songsScrollController.animateTo(
//             0,
//             duration: const Duration(milliseconds: 800),
//             curve: Curves.easeInOut,
//           );
//         }
//       }
//     });
//   }

//   void _addDummyMovies() {
//     final now = DateTime.now();

//     topMovies.value = [
//       Movie(
//         id: '1',
//         title: 'Inception',
//         images: ['https://via.placeholder.com/400x600?text=Inception'],
//         description:
//             'A thief who steals corporate secrets through the use of dream-sharing technology.',
//         releaseDate: DateTime(2010, 7, 16),
//         genres: ['Sci-Fi', 'Action', 'Thriller'],
//         averageRating: 4.8,
//         reviewCount: 1254,
//         director: 'Christopher Nolan',
//         cast: ['Leonardo DiCaprio', 'Joseph Gordon-Levitt', 'Ellen Page'],
//         durationMinutes: 148,
//         createdAt: now,
//         updatedAt: now,
//       ),
//       Movie(
//         id: '2',
//         title: 'The Shawshank Redemption',
//         images: ['https://via.placeholder.com/400x600?text=Shawshank'],
//         description:
//             'Two imprisoned men bond over a number of years, finding solace and redemption through acts of common decency.',
//         releaseDate: DateTime(1994, 9, 22),
//         genres: ['Drama', 'Crime'],
//         averageRating: 4.9,
//         reviewCount: 2548,
//         director: 'Frank Darabont',
//         cast: ['Tim Robbins', 'Morgan Freeman', 'Bob Gunton'],
//         durationMinutes: 142,
//         createdAt: now,
//         updatedAt: now,
//       ),
//       Movie(
//         id: '3',
//         title: 'Pulp Fiction',
//         images: ['https://via.placeholder.com/400x600?text=PulpFiction'],
//         description:
//             'The lives of two mob hitmen, a boxer, a gangster and his wife intertwine in four tales of violence and redemption.',
//         releaseDate: DateTime(1994, 10, 14),
//         genres: ['Crime', 'Drama'],
//         averageRating: 4.7,
//         reviewCount: 1876,
//         director: 'Quentin Tarantino',
//         cast: ['John Travolta', 'Uma Thurman', 'Samuel L. Jackson'],
//         durationMinutes: 154,
//         createdAt: now,
//         updatedAt: now,
//       ),
//       Movie(
//         id: '4',
//         title: 'The Dark Knight',
//         images: ['https://via.placeholder.com/400x600?text=DarkKnight'],
//         description:
//             'When the menace known as the Joker wreaks havoc on Gotham City, Batman must accept one of the greatest tests of his ability to fight injustice.',
//         releaseDate: DateTime(2008, 7, 18),
//         genres: ['Action', 'Crime', 'Drama'],
//         averageRating: 4.9,
//         reviewCount: 2354,
//         director: 'Christopher Nolan',
//         cast: ['Christian Bale', 'Heath Ledger', 'Aaron Eckhart'],
//         durationMinutes: 152,
//         createdAt: now,
//         updatedAt: now,
//       ),
//       Movie(
//         id: '5',
//         title: 'The Godfather',
//         images: ['https://via.placeholder.com/400x600?text=Godfather'],
//         description:
//             'The aging patriarch of an organized crime dynasty transfers control to his reluctant son.',
//         releaseDate: DateTime(1972, 3, 24),
//         genres: ['Crime', 'Drama'],
//         averageRating: 4.9,
//         reviewCount: 1725,
//         director: 'Francis Ford Coppola',
//         cast: ['Marlon Brando', 'Al Pacino', 'James Caan'],
//         durationMinutes: 175,
//         createdAt: now,
//         updatedAt: now,
//       ),
//     ];
//   }

//   void _addDummyTeledramas() {
//     final now = DateTime.now();

//     topTeledramas.value = [
//       Teledrama(
//         id: '1',
//         title: 'Breaking Bad',
//         images: ['https://via.placeholder.com/300x450?text=BreakingBad'],
//         description:
//             'A high school chemistry teacher turned methamphetamine manufacturer.',
//         releaseDate: DateTime(2008, 1, 20),
//         genres: ['Crime', 'Drama', 'Thriller'],
//         averageRating: 4.9,
//         reviewCount: 1845,
//         seasons: 5,
//         episodes: 62,
//         network: 'AMC',
//         cast: ['Bryan Cranston', 'Aaron Paul', 'Anna Gunn'],
//         createdAt: now,
//         updatedAt: now,
//       ),
//       Teledrama(
//         id: '2',
//         title: 'Game of Thrones',
//         images: ['https://via.placeholder.com/300x450?text=GameOfThrones'],
//         description:
//             'Nine noble families fight for control over the lands of Westeros.',
//         releaseDate: DateTime(2011, 4, 17),
//         genres: ['Action', 'Adventure', 'Drama'],
//         averageRating: 4.7,
//         reviewCount: 2367,
//         seasons: 8,
//         episodes: 73,
//         network: 'HBO',
//         cast: ['Emilia Clarke', 'Kit Harington', 'Peter Dinklage'],
//         createdAt: now,
//         updatedAt: now,
//       ),
//       Teledrama(
//         id: '3',
//         title: 'Stranger Things',
//         images: ['https://via.placeholder.com/300x450?text=StrangerThings'],
//         description:
//             'When a young boy disappears, his friends, family, and police are drawn into a mystery.',
//         releaseDate: DateTime(2016, 7, 15),
//         genres: ['Drama', 'Fantasy', 'Horror'],
//         averageRating: 4.8,
//         reviewCount: 1967,
//         seasons: 4,
//         episodes: 34,
//         network: 'Netflix',
//         cast: ['Millie Bobby Brown', 'Finn Wolfhard', 'Winona Ryder'],
//         createdAt: now,
//         updatedAt: now,
//       ),
//       Teledrama(
//         id: '4',
//         title: 'The Crown',
//         images: ['https://via.placeholder.com/300x450?text=TheCrown'],
//         description:
//             'Follows the political rivalries and romance of Queen Elizabeth II\'s reign.',
//         releaseDate: DateTime(2016, 11, 4),
//         genres: ['Biography', 'Drama', 'History'],
//         averageRating: 4.7,
//         reviewCount: 1254,
//         seasons: 5,
//         episodes: 50,
//         network: 'Netflix',
//         cast: ['Claire Foy', 'Olivia Colman', 'Imelda Staunton'],
//         createdAt: now,
//         updatedAt: now,
//       ),
//     ];
//   }

//   void _addDummySongs() {
//     final now = DateTime.now();

//     topSongs.value = [
//       Song(
//         id: '1',
//         title: 'Bohemian Rhapsody',
//         images: ['https://via.placeholder.com/300x300?text=BohemianRhapsody'],
//         description:
//             'A six-minute suite, consisting of several sections without a chorus.',
//         releaseDate: DateTime(1975, 10, 31),
//         genres: ['Rock', 'Progressive Rock'],
//         averageRating: 4.9,
//         reviewCount: 3254,
//         artist: 'Queen',
//         album: 'A Night at the Opera',
//         durationSeconds: 354,
//         featuring: [],
//         createdAt: now,
//         updatedAt: now,
//       ),
//       Song(
//         id: '2',
//         title: 'Imagine',
//         images: ['https://via.placeholder.com/300x300?text=Imagine'],
//         description:
//             'A song encouraging listeners to imagine a world of peace.',
//         releaseDate: DateTime(1971, 10, 11),
//         genres: ['Soft Rock', 'Piano Rock'],
//         averageRating: 4.8,
//         reviewCount: 2187,
//         artist: 'John Lennon',
//         album: 'Imagine',
//         durationSeconds: 183,
//         featuring: [],
//         createdAt: now,
//         updatedAt: now,
//       ),
//       Song(
//         id: '3',
//         title: 'Billie Jean',
//         images: ['https://via.placeholder.com/300x300?text=BillieJean'],
//         description:
//             'A song about a woman who claims the narrator is the father of her child.',
//         releaseDate: DateTime(1983, 1, 2),
//         genres: ['Pop', 'R&B', 'Dance'],
//         averageRating: 4.9,
//         reviewCount: 2876,
//         artist: 'Michael Jackson',
//         album: 'Thriller',
//         durationSeconds: 293,
//         featuring: [],
//         createdAt: now,
//         updatedAt: now,
//       ),
//       Song(
//         id: '4',
//         title: 'Like a Rolling Stone',
//         images: ['https://via.placeholder.com/300x300?text=RollingStone'],
//         description:
//             'A confrontational song addressing a woman who has fallen from grace.',
//         releaseDate: DateTime(1965, 7, 20),
//         genres: ['Rock', 'Folk Rock'],
//         averageRating: 4.7,
//         reviewCount: 1547,
//         artist: 'Bob Dylan',
//         album: 'Highway 61 Revisited',
//         durationSeconds: 373,
//         featuring: [],
//         createdAt: now,
//         updatedAt: now,
//       ),
//       // Add more songs for a better scrolling experience
//       Song(
//         id: '5',
//         title: 'Smells Like Teen Spirit',
//         images: ['https://via.placeholder.com/300x300?text=TeenSpirit'],
//         description: 'An anthem for apathetic kids of Generation X.',
//         releaseDate: DateTime(1991, 9, 10),
//         genres: ['Grunge', 'Alternative Rock'],
//         averageRating: 4.8,
//         reviewCount: 2367,
//         artist: 'Nirvana',
//         album: 'Nevermind',
//         durationSeconds: 301,
//         featuring: [],
//         createdAt: now,
//         updatedAt: now,
//       ),
//       Song(
//         id: '6',
//         title: 'Hotel California',
//         images: ['https://via.placeholder.com/300x300?text=HotelCalifornia'],
//         description:
//             'A song about the excesses of American culture and the dark underside of the Hollywood scene.',
//         releaseDate: DateTime(1977, 2, 22),
//         genres: ['Rock', 'Soft Rock'],
//         averageRating: 4.9,
//         reviewCount: 2145,
//         artist: 'Eagles',
//         album: 'Hotel California',
//         durationSeconds: 391,
//         featuring: [],
//         createdAt: now,
//         updatedAt: now,
//       ),
//     ];
//   }

//   void _addDummyBooks() {
//     final now = DateTime.now();

//     topBooks.value = [
//       Book(
//         id: '1',
//         title: 'To Kill a Mockingbird',
//         images: ['https://via.placeholder.com/300x450?text=ToKillAMockingbird'],
//         description:
//             'The story of a young girl confronting the harsh realities of racial inequality in her hometown.',
//         releaseDate: DateTime(1960, 7, 11),
//         genres: ['Classic', 'Fiction'],
//         averageRating: 4.8,
//         reviewCount: 2456,
//         author: 'Harper Lee',
//         publisher: 'J. B. Lippincott & Co.',
//         pages: 281,
//         isbn: '978-0-06-112008-4',
//         createdAt: now,
//         updatedAt: now,
//       ),
//       Book(
//         id: '2',
//         title: '1984',
//         images: ['https://via.placeholder.com/300x450?text=1984'],
//         description:
//             'A dystopian novel set in a totalitarian society where individualism and independent thinking are persecuted.',
//         releaseDate: DateTime(1949, 6, 8),
//         genres: ['Dystopian', 'Political Fiction'],
//         averageRating: 4.7,
//         reviewCount: 1987,
//         author: 'George Orwell',
//         publisher: 'Secker & Warburg',
//         pages: 328,
//         isbn: '978-0-452-28423-4',
//         createdAt: now,
//         updatedAt: now,
//       ),
//       Book(
//         id: '3',
//         title: 'The Great Gatsby',
//         images: ['https://via.placeholder.com/300x450?text=GreatGatsby'],
//         description:
//             'A tragedy set in the roaring twenties that examines the hollowness of the American Dream.',
//         releaseDate: DateTime(1925, 4, 10),
//         genres: ['Classic', 'Fiction'],
//         averageRating: 4.5,
//         reviewCount: 1654,
//         author: 'F. Scott Fitzgerald',
//         publisher: 'Charles Scribner\'s Sons',
//         pages: 180,
//         isbn: '978-0-7432-7356-5',
//         createdAt: now,
//         updatedAt: now,
//       ),
//       Book(
//         id: '4',
//         title: 'Harry Potter and the Philosopher\'s Stone',
//         images: ['https://via.placeholder.com/300x450?text=HarryPotter'],
//         description:
//             'The first novel in the Harry Potter series and follows young wizard Harry Potter\'s first year at Hogwarts School.',
//         releaseDate: DateTime(1997, 6, 26),
//         genres: ['Fantasy', 'Young Adult'],
//         averageRating: 4.9,
//         reviewCount: 3254,
//         author: 'J.K. Rowling',
//         publisher: 'Bloomsbury',
//         pages: 223,
//         isbn: '978-0-7475-3269-9',
//         createdAt: now,
//         updatedAt: now,
//       ),
//     ];
//   }
// }
