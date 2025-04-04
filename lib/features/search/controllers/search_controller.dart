import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/SearchItemModel.dart';

class SimpleSearchController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Text controller for the search field
  final TextEditingController searchController = TextEditingController();

  // Non-reactive variables for GetBuilder approach
  String selectedCategory = 'All';
  List<SearchItemModel> searchResults = [];
  bool isLoading = false;
  bool hasSearched = false;

  // Available categories
  final List<String> categories = [
    'All',
    'Movies',
    'TV Shows',
    'Songs',
    'Books',
  ];

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  // Perform search based on query text and selected category
  Future<void> performSearch(String query) async {
    if (query.isEmpty) {
      clearSearch();
      return;
    }

    isLoading = true;
    hasSearched = true;
    update(); // Notify UI

    try {
      // Different collections based on the selected category
      List<String> collections = [];

      if (selectedCategory == 'All') {
        collections = ['movies', 'teledramas', 'songs', 'books'];
      } else if (selectedCategory == 'Movies') {
        collections = ['movies'];
      } else if (selectedCategory == 'TV Shows') {
        collections = ['teledramas'];
      } else if (selectedCategory == 'Songs') {
        collections = ['songs'];
      } else if (selectedCategory == 'Books') {
        collections = ['books'];
      }

      final List<SearchItemModel> results = [];
      final queryLowerCase = query.toLowerCase();

      // Search in each collection
      for (final collection in collections) {
        try {
          // Different search strategies
          QuerySnapshot snapshot;

          // Strategy 1: Search by exact title prefix (most accurate)
          try {
            snapshot =
                await _firestore
                    .collection(collection)
                    .where(
                      'title_lowercase',
                      isGreaterThanOrEqualTo: queryLowerCase,
                    )
                    .where(
                      'title_lowercase',
                      isLessThanOrEqualTo: '$queryLowerCase\uf8ff',
                    )
                    .limit(10)
                    .get();

            // If no results from prefix search and not already trying a different strategy
            if (snapshot.docs.isEmpty) {
              // Strategy 2: Try searching by title field instead
              try {
                snapshot =
                    await _firestore
                        .collection(collection)
                        .orderBy('title')
                        .startAt([queryLowerCase])
                        .endAt(['$queryLowerCase\uf8ff'])
                        .limit(10)
                        .get();
              } catch (e) {
                print('Failed title field search for $collection: $e');
              }
            }
          } catch (e) {
            // If title_lowercase field doesn't exist, fallback to regular title field
            print('Falling back to title search for $collection: $e');
            try {
              snapshot =
                  await _firestore
                      .collection(collection)
                      .orderBy('title')
                      .startAt([queryLowerCase])
                      .endAt(['$queryLowerCase\uf8ff'])
                      .limit(10)
                      .get();
            } catch (e2) {
              print('Failed fallback title search for $collection: $e2');
              // Initialize with empty snapshot to avoid null errors
              snapshot = await _firestore.collection(collection).limit(0).get();
            }
          }

          // Process the results
          for (final doc in snapshot.docs) {
            final data = doc.data() as Map<String, dynamic>;

            // Skip duplicates if any
            if (results.any((item) => item.id == doc.id)) continue;

            // Get type-specific subtitles
            String subtitle = '';
            if (collection == 'movies') {
              subtitle = data['director'] ?? '';
            } else if (collection == 'teledramas') {
              subtitle = data['network'] ?? '';
            } else if (collection == 'songs') {
              subtitle = data['artist'] ?? '';
            } else if (collection == 'books') {
              subtitle = data['author'] ?? '';
            }

            // Create a SearchItemModel instance
            results.add(
              SearchItemModel(
                id: doc.id,
                title: data['title'] ?? 'Unknown',
                subtitle: subtitle,
                imageUrl:
                    data['images'] != null &&
                            (data['images'] as List).isNotEmpty
                        ? data['images'][0]
                        : '',
                type:
                    collection == 'teledramas'
                        ? 'teledrama'
                        : collection.substring(0, collection.length - 1),
                rating: (data['averageRating'] ?? 0.0).toDouble(),
              ),
            );
          }
        } catch (e) {
          print('Error searching in $collection: $e');
        }
      }

      // If no results found with title search, try more flexible search strategies
      if (results.isEmpty) {
        await _performFlexibleSearch(collections, query, results);
      }

      // Update the results
      searchResults = results;
    } catch (e) {
      print('Search error: $e');
      searchResults = [];
    } finally {
      isLoading = false;
      update(); // Notify UI about changes
    }
  }

  // More flexible search using keywords or multiple fields
  Future<void> _performFlexibleSearch(
    List<String> collections,
    String query,
    List<SearchItemModel> results,
  ) async {
    final queryLowerCase =
        query.toLowerCase(); // Define it here to fix the error
    final queryWords = queryLowerCase.split(' ');

    // Try to look for partial matches in various fields
    for (final collection in collections) {
      try {
        // Strategy 1: Try to search by keywords array if it exists
        try {
          final keywordSnapshot =
              await _firestore
                  .collection(collection)
                  .where(
                    'keywords',
                    arrayContainsAny:
                        queryWords.length > 5
                            ? queryWords.sublist(0, 5)
                            : queryWords,
                  )
                  .limit(10)
                  .get();

          for (final doc in keywordSnapshot.docs) {
            final data = doc.data();

            // Skip duplicates
            if (results.any((item) => item.id == doc.id)) continue;

            // Get type-specific subtitles
            String subtitle = '';
            if (collection == 'movies') {
              subtitle = data['director'] ?? '';
            } else if (collection == 'teledramas') {
              subtitle = data['network'] ?? '';
            } else if (collection == 'songs') {
              subtitle = data['artist'] ?? '';
            } else if (collection == 'books') {
              subtitle = data['author'] ?? '';
            }

            results.add(
              SearchItemModel(
                id: doc.id,
                title: data['title'] ?? 'Unknown',
                subtitle: subtitle,
                imageUrl:
                    data['images'] != null &&
                            (data['images'] as List).isNotEmpty
                        ? data['images'][0]
                        : '',
                type:
                    collection == 'teledramas'
                        ? 'teledrama'
                        : collection.substring(0, collection.length - 1),
                rating: (data['averageRating'] ?? 0.0).toDouble(),
              ),
            );
          }
        } catch (e) {
          print('Keywords search failed for $collection: $e');
        }

        // Strategy 2: Try to search in other fields like description, artist, etc.
        if (collection == 'movies' || collection == 'teledramas') {
          // Try searching by cast or director names
          try {
            final castSnapshot =
                await _firestore
                    .collection(collection)
                    .where('cast_lowercase', arrayContainsAny: queryWords)
                    .limit(5)
                    .get();

            for (final doc in castSnapshot.docs) {
              final data = doc.data();

              // Skip duplicates
              if (results.any((item) => item.id == doc.id)) continue;

              String subtitle = '';
              if (collection == 'movies') {
                subtitle = data['director'] ?? '';
              } else {
                subtitle = data['network'] ?? '';
              }

              results.add(
                SearchItemModel(
                  id: doc.id,
                  title: data['title'] ?? 'Unknown',
                  subtitle: subtitle,
                  imageUrl:
                      data['images'] != null &&
                              (data['images'] as List).isNotEmpty
                          ? data['images'][0]
                          : '',
                  type:
                      collection == 'teledramas'
                          ? 'teledrama'
                          : collection.substring(0, collection.length - 1),
                  rating: (data['averageRating'] ?? 0.0).toDouble(),
                ),
              );
            }
          } catch (e) {
            print('Cast/director search failed for $collection: $e');
          }
        } else if (collection == 'songs') {
          // Try searching by artist or album
          try {
            final artistSnapshot =
                await _firestore
                    .collection(collection)
                    .where(
                      'artist_lowercase',
                      isGreaterThanOrEqualTo: queryLowerCase,
                    )
                    .where(
                      'artist_lowercase',
                      isLessThanOrEqualTo: '$queryLowerCase\uf8ff',
                    )
                    .limit(5)
                    .get();

            for (final doc in artistSnapshot.docs) {
              final data = doc.data();

              // Skip duplicates
              if (results.any((item) => item.id == doc.id)) continue;

              results.add(
                SearchItemModel(
                  id: doc.id,
                  title: data['title'] ?? 'Unknown',
                  subtitle: data['artist'] ?? '',
                  imageUrl:
                      data['images'] != null &&
                              (data['images'] as List).isNotEmpty
                          ? data['images'][0]
                          : '',
                  type: 'song',
                  rating: (data['averageRating'] ?? 0.0).toDouble(),
                ),
              );
            }
          } catch (e) {
            print('Artist search failed for songs: $e');
          }
        } else if (collection == 'books') {
          // Try searching by author
          try {
            final authorSnapshot =
                await _firestore
                    .collection(collection)
                    .where(
                      'author_lowercase',
                      isGreaterThanOrEqualTo: queryLowerCase,
                    )
                    .where(
                      'author_lowercase',
                      isLessThanOrEqualTo: '$queryLowerCase\uf8ff',
                    )
                    .limit(5)
                    .get();

            for (final doc in authorSnapshot.docs) {
              final data = doc.data();

              // Skip duplicates
              if (results.any((item) => item.id == doc.id)) continue;

              results.add(
                SearchItemModel(
                  id: doc.id,
                  title: data['title'] ?? 'Unknown',
                  subtitle: data['author'] ?? '',
                  imageUrl:
                      data['images'] != null &&
                              (data['images'] as List).isNotEmpty
                          ? data['images'][0]
                          : '',
                  type: 'book',
                  rating: (data['averageRating'] ?? 0.0).toDouble(),
                ),
              );
            }
          } catch (e) {
            print('Author search failed for books: $e');
          }
        }
      } catch (e) {
        print('Error in flexible search for $collection: $e');
      }
    }
  }

  // Clear search results
  void clearSearch() {
    searchResults = [];
    hasSearched = false;
    update(); // Notify UI
  }

  // Update the selected category and re-run search if there's a query
  void updateCategoryFilter(String category) {
    selectedCategory = category;
    update(); // Notify UI

    if (searchController.text.isNotEmpty) {
      performSearch(searchController.text);
    }
  }
}
