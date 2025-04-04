import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../models/SearchItemModel.dart';

class SearchResultItem extends StatelessWidget {
  final SearchItemModel item;
  final VoidCallback onTap;

  const SearchResultItem({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 360;

    // Get type-specific colors and icons
    Color getAccentColor() {
      switch (item.type) {
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

    IconData getTypeIcon() {
      switch (item.type) {
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

    String getTypeLabel() {
      switch (item.type) {
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

    final accentColor = getAccentColor();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentColor.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.all(isSmallScreen ? 10.0 : 12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Media thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl:
                        item.imageUrl.isNotEmpty
                            ? item.imageUrl
                            : 'https://via.placeholder.com/100x150?text=${item.title}',
                    width: isSmallScreen ? 70 : 80,
                    height: isSmallScreen ? 105 : 120,
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
                              size: 24,
                            ),
                          ),
                        ),
                  ),
                ),
                const SizedBox(width: 12),

                // Media info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Type badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: accentColor.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(getTypeIcon(), color: Colors.white, size: 12),
                            const SizedBox(width: 4),
                            Text(
                              getTypeLabel(),
                              style: textTheme.labelSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Title
                      Text(
                        item.title,
                        style: textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),

                      // Subtitle (artist, author, etc.)
                      if (item.subtitle.isNotEmpty)
                        Text(
                          item.subtitle,
                          style: textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: 8),

                      // Rating
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: Colors.amber,
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            item.rating.toStringAsFixed(1),
                            style: textTheme.bodySmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // View details icon
                Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.grey.shade400,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
