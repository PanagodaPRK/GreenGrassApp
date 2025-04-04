class SearchItemModel {
  final String id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final String type; // 'movie', 'teledrama', 'song', 'book'
  final double rating;

  SearchItemModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.type,
    required this.rating,
  });
}
