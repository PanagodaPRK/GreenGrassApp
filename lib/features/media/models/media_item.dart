abstract class MediaItem {
  final String id;
  final String title;
  final List<String> images;
  final String description;
  final DateTime releaseDate;
  final List<String> genres;
  final double averageRating;
  final int reviewCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  MediaItem({
    required this.id,
    required this.title,
    required this.images,
    required this.description,
    required this.releaseDate,
    required this.genres,
    required this.averageRating,
    required this.reviewCount,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toCommonMap() {
    return {
      'title': title,
      'images': images,
      'description': description,
      'releaseDate': releaseDate,
      'genres': genres,
      'averageRating': averageRating,
      'reviewCount': reviewCount,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
