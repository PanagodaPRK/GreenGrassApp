import 'package:cloud_firestore/cloud_firestore.dart';

import 'media_item.dart';

class Song extends MediaItem {
  final String artist;
  final String album;
  final int durationSeconds;
  final List<String> featuring;

  Song({
    required super.id,
    required super.title,
    required super.images,
    required super.description,
    required super.releaseDate,
    required super.genres,
    required super.averageRating,
    required super.reviewCount,
    required this.artist,
    required this.album,
    required this.durationSeconds,
    required this.featuring,
    required super.createdAt,
    required super.updatedAt,
  });

  factory Song.fromMap(Map<String, dynamic> map, String id) {
    return Song(
      id: id,
      title: map['title'] ?? '',
      images: List<String>.from(map['images'] ?? []),
      description: map['description'] ?? '',
      releaseDate: (map['releaseDate'] as Timestamp).toDate(),
      genres: List<String>.from(map['genres'] ?? []),
      averageRating: (map['averageRating'] ?? 0.0).toDouble(),
      reviewCount: map['reviewCount'] ?? 0,
      artist: map['artist'] ?? '',
      album: map['album'] ?? '',
      durationSeconds: map['durationSeconds'] ?? 0,
      featuring: List<String>.from(map['featuring'] ?? []),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    final commonMap = super.toCommonMap();
    return {
      ...commonMap,
      'artist': artist,
      'album': album,
      'durationSeconds': durationSeconds,
      'featuring': featuring,
    };
  }
}
