import 'package:cloud_firestore/cloud_firestore.dart';

import 'media_item.dart';

class Teledrama extends MediaItem {
  final int seasons;
  final int episodes;
  final String network;
  final List<String> cast;

  Teledrama({
    required super.id,
    required super.title,
    required super.images,
    required super.description,
    required super.releaseDate,
    required super.genres,
    required super.averageRating,
    required super.reviewCount,
    required this.seasons,
    required this.episodes,
    required this.network,
    required this.cast,
    required super.createdAt,
    required super.updatedAt,
  });

  factory Teledrama.fromMap(Map<String, dynamic> map, String id) {
    return Teledrama(
      id: id,
      title: map['title'] ?? '',
      images: List<String>.from(map['images'] ?? []),
      description: map['description'] ?? '',
      releaseDate: (map['releaseDate'] as Timestamp).toDate(),
      genres: List<String>.from(map['genres'] ?? []),
      averageRating: (map['averageRating'] ?? 0.0).toDouble(),
      reviewCount: map['reviewCount'] ?? 0,
      seasons: map['seasons'] ?? 0,
      episodes: map['episodes'] ?? 0,
      network: map['network'] ?? '',
      cast: List<String>.from(map['cast'] ?? []),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    final commonMap = super.toCommonMap();
    return {
      ...commonMap,
      'seasons': seasons,
      'episodes': episodes,
      'network': network,
      'cast': cast,
    };
  }
}
