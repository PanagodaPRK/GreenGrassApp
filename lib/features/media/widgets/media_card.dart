import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/rating_stars.dart';

class MediaCard extends StatelessWidget {
  final dynamic item;
  final String type;
  final String title;
  final String subtitle;
  final String imageUrl;
  final double rating;
  final List<String> genres;
  final String id;

  const MediaCard({
    super.key,
    required this.item,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.rating,
    required this.genres,
    required this.id,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    // Different accent colors for different media types
    Color getAccentColor() {
      switch (type) {
        case 'movie':
          return Colors.red.shade400;
        case 'teledrama':
          return AppColors.primary;
        case 'song':
          return Colors.purple.shade400;
        case 'book':
          return Colors.amber.shade700;
        default:
          return AppColors.primary;
      }
    }

    // Different icons for different media types
    IconData getTypeIcon() {
      switch (type) {
        case 'movie':
          return Icons.movie_outlined;
        case 'teledrama':
          return Icons.tv_outlined;
        case 'song':
          return Icons.music_note_outlined;
        case 'book':
          return Icons.book_outlined;
        default:
          return Icons.theaters_outlined;
      }
    }

    final accentColor = getAccentColor();

    return Container(
      height: 30,
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // Navigate to media details
            Get.toNamed('/media-details', arguments: {'id': id, 'type': type});
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Media image with overlay
              Stack(
                children: [
                  // Image
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    child: CachedNetworkImage(
                      imageUrl:
                          imageUrl.isNotEmpty
                              ? imageUrl
                              : 'https://via.placeholder.com/300x450?text=$title',
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder:
                          (context, url) => Container(
                            color: Colors.grey[800],
                            child: Center(
                              child: CircularProgressIndicator(
                                color: accentColor,
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                      errorWidget:
                          (context, url, error) => Container(
                            color: Colors.grey[800],
                            child: Center(
                              child: Icon(
                                getTypeIcon(),
                                color: Colors.white,
                                size: 48,
                              ),
                            ),
                          ),
                    ),
                  ),

                  // Rating badge
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: accentColor.withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: Colors.amber,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            rating.toStringAsFixed(1),
                            style: textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Media type badge
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(getTypeIcon(), color: Colors.white, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            _getTypeLabel(type),
                            style: textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Media info
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      title,
                      style: textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Subtitle
                    Text(
                      subtitle,
                      style: textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // Genres
                    SizedBox(
                      height: 26,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: genres.length > 2 ? 2 : genres.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: EdgeInsets.only(
                              right: index < genres.length - 1 ? 8 : 0,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: accentColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: accentColor.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              genres[index],
                              style: textTheme.labelSmall?.copyWith(
                                color: accentColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper to get readable type label
  String _getTypeLabel(String type) {
    switch (type) {
      case 'movie':
        return 'Movie';
      case 'teledrama':
        return 'TV Show';
      case 'song':
        return 'Song';
      case 'book':
        return 'Book';
      default:
        return 'Media';
    }
  }
}
