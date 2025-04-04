import 'package:cloud_firestore/cloud_firestore.dart';

import 'media_item.dart';

class Movie extends MediaItem {
  final String director;
  final List<String> cast;
  final int durationMinutes;

  Movie({
    required super.id,
    required super.title,
    required super.images,
    required super.description,
    required super.releaseDate,
    required super.genres,
    required super.averageRating,
    required super.reviewCount,
    required this.director,
    required this.cast,
    required this.durationMinutes,
    required super.createdAt,
    required super.updatedAt,
  });

  factory Movie.fromMap(Map<String, dynamic> map, String id) {
    return Movie(
      id: id,
      title: map['title'] ?? '',
      images: List<String>.from(map['images'] ?? []),
      description: map['description'] ?? '',
      releaseDate: (map['releaseDate'] as Timestamp).toDate(),
      genres: List<String>.from(map['genres'] ?? []),
      averageRating: (map['averageRating'] ?? 0.0).toDouble(),
      reviewCount: map['reviewCount'] ?? 0,
      director: map['director'] ?? '',
      cast: List<String>.from(map['cast'] ?? []),
      durationMinutes: map['durationMinutes'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    final commonMap = super.toCommonMap();
    return {
      ...commonMap,
      'director': director,
      'cast': cast,
      'durationMinutes': durationMinutes,
    };
  }
}
