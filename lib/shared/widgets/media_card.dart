// lib/shared/widgets/media_card.dart
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'rating_stars.dart';

class MediaCard extends StatelessWidget {
  final String id;
  final String title;
  final String imageUrl;
  final List<String> genres;
  final double rating;
  final int reviewCount;
  final String mediaType; // 'movie', 'teledrama', 'song', 'book'
  final VoidCallback onTap;

  const MediaCard({
    super.key,
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.genres,
    required this.rating,
    required this.reviewCount,
    required this.mediaType,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: Image.network(
                imageUrl,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 180,
                  width: double.infinity,
                  color: Colors.grey.shade300,
                  child: const Icon(
                    Icons.image_not_supported,
                    size: 48,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),

                  // Genres
                  if (genres.isNotEmpty)
                    SizedBox(
                      height: 24,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: genres.length > 3 ? 3 : genres.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: 4),
                        itemBuilder: (context, index) => Chip(
                          label: Text(
                            genres[index],
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                            ),
                          ),
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 0),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),

                  // Rating and Review count
                  Row(
                    children: [
                      RatingStars(
                        rating: rating,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '($reviewCount ${reviewCount == 1 ? 'review' : 'reviews'})',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),

                  // Media type indicator
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getMediaTypeColor(mediaType),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        mediaType.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getMediaTypeColor(String mediaType) {
    switch (mediaType.toLowerCase()) {
      case 'movie':
        return Colors.red.shade700;
      case 'teledrama':
        return Colors.blue.shade700;
      case 'song':
        return Colors.purple.shade700;
      case 'book':
        return Colors.amber.shade700;
      default:
        return AppColors.primary;
    }
  }
}
