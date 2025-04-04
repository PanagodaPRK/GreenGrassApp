import 'package:cloud_firestore/cloud_firestore.dart';

import 'media_item.dart';

class Book extends MediaItem {
  final String author;
  final String publisher;
  final int pages;
  final String isbn;

  Book({
    required super.id,
    required super.title,
    required super.images,
    required super.description,
    required super.releaseDate,
    required super.genres,
    required super.averageRating,
    required super.reviewCount,
    required this.author,
    required this.publisher,
    required this.pages,
    required this.isbn,
    required super.createdAt,
    required super.updatedAt,
  });

  factory Book.fromMap(Map<String, dynamic> map, String id) {
    return Book(
      id: id,
      title: map['title'] ?? '',
      images: List<String>.from(map['images'] ?? []),
      description: map['description'] ?? '',
      releaseDate: (map['releaseDate'] as Timestamp).toDate(),
      genres: List<String>.from(map['genres'] ?? []),
      averageRating: (map['averageRating'] ?? 0.0).toDouble(),
      reviewCount: map['reviewCount'] ?? 0,
      author: map['author'] ?? '',
      publisher: map['publisher'] ?? '',
      pages: map['pages'] ?? 0,
      isbn: map['isbn'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    final commonMap = super.toCommonMap();
    return {
      ...commonMap,
      'author': author,
      'publisher': publisher,
      'pages': pages,
      'isbn': isbn,
    };
  }
}
