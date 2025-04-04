import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../reviews/models/comment.dart';
import '../../reviews/models/review.dart';
import '../controllers/medai_details_controller.dart';
import '../../../shared/widgets/rating_stars.dart';

class MediaDetailsScreen extends StatelessWidget {
  const MediaDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final MediaDetailsController controller = Get.put(MediaDetailsController());
    final textTheme = Theme.of(context).textTheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 360;

    // Apply system UI overlay style for immersive experience
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildLoadingIndicator();
        }

        if (controller.hasError.value) {
          return _buildErrorWidget(controller);
        }

        if (controller.mediaItem.value == null) {
          return _buildEmptyState();
        }

        return CustomScrollView(
          slivers: [
            // App Bar with media poster and title
            _buildSliverAppBar(context, controller),

            // Media details content
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Media quick stats
                  _buildQuickStats(context, controller),

                  // Media description
                  _buildDescription(context, controller),

                  // Media specific details
                  _buildMediaSpecificDetails(context, controller),

                  // Reviews section
                  _buildReviewsSection(context, controller),
                ],
              ),
            ),
          ],
        );
      }),
      floatingActionButton: Obx(
        () =>
            controller.isLoading.value || controller.mediaItem.value == null
                ? const SizedBox.shrink()
                : FloatingActionButton.extended(
                  onPressed: () => controller.showAddReviewDialog(),
                  backgroundColor: AppColors.primary,
                  icon: const Icon(Icons.rate_review_outlined),
                  label: const Text('Write Review'),
                ),
      ),
    );
  }

  // Loading indicator
  Widget _buildLoadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.surfaceDark,
      ),
    );
  }

  // Error display
  Widget _buildErrorWidget(MediaDetailsController controller) {
    final screenWidth = MediaQuery.of(Get.context!).size.width;
    final bool isSmallScreen = screenWidth < 360;

    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: Colors.red,
            size: isSmallScreen ? 48 : 60,
          ),
          SizedBox(height: isSmallScreen ? 12.0 : 16.0),
          Text(
            'Unable to load media details',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: isSmallScreen ? 16.0 : 18.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: isSmallScreen ? 6.0 : 8.0),
          Text(
            controller.errorMessage.value,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: isSmallScreen ? 12.0 : 14.0,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isSmallScreen ? 12.0 : 16.0),
          ElevatedButton(
            onPressed: () => controller.loadMediaDetails(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
          ),
          SizedBox(height: isSmallScreen ? 12.0 : 16.0),
          TextButton(onPressed: () => Get.back(), child: const Text('Go Back')),
        ],
      ),
    );
  }

  // Empty state
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off_rounded, color: Colors.grey, size: 64),
          const SizedBox(height: 16),
          Text(
            'Media not found',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextButton(onPressed: () => Get.back(), child: const Text('Go Back')),
        ],
      ),
    );
  }

  // Sliver App Bar with poster and backdrop
  Widget _buildSliverAppBar(
    BuildContext context,
    MediaDetailsController controller,
  ) {
    final textTheme = Theme.of(context).textTheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 360;
    final item = controller.mediaItem.value;
    final mediaType = controller.mediaType.value;

    // Define dynamic colors based on media type
    Color getAccentColor() {
      switch (mediaType) {
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

    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      stretch: true,
      backgroundColor: AppColors.surfaceDark,
      leading: GestureDetector(
        onTap: () => Get.back(),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black38,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        ),
      ),
      actions: [
        // Share button
        GestureDetector(
          onTap: () => controller.shareMedia(),
          child: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black38,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.share_rounded, color: Colors.white),
          ),
        ),
        // Favorite button
        Obx(
          () => GestureDetector(
            onTap: () => controller.toggleFavorite(),
            child: Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black38,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                controller.isFavorite.value
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                color: controller.isFavorite.value ? Colors.red : Colors.white,
              ),
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Backdrop image
            item?.images.isNotEmpty == true
                ? CachedNetworkImage(
                  imageUrl: item!.images[0],
                  fit: BoxFit.cover,
                  placeholder:
                      (context, url) => Container(color: Colors.grey[900]),
                  errorWidget:
                      (context, url, error) => Container(
                        color: Colors.grey[900],
                        child: const Icon(
                          Icons.broken_image_rounded,
                          color: Colors.white30,
                          size: 48,
                        ),
                      ),
                )
                : Container(color: Colors.grey[900]),

            // Gradient overlay for readability
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                    Colors.black.withOpacity(0.9),
                  ],
                  stops: const [0.3, 0.7, 1.0],
                ),
              ),
            ),

            // Media info overlay at bottom
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Type badge
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 8.0 : 10.0,
                      vertical: isSmallScreen ? 4.0 : 5.0,
                    ),
                    decoration: BoxDecoration(
                      color: getAccentColor(),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getTypeLabel(mediaType),
                      style: textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 8.0 : 12.0),

                  // Title
                  Text(
                    item?.title ?? '',
                    style: textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 4.0 : 6.0),

                  // Year and duration/details
                  Row(
                    children: [
                      // Year
                      Text(
                        item?.releaseDate != null
                            ? DateFormat('yyyy').format(item!.releaseDate)
                            : '',
                        style: textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Dot separator
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white70,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Duration or additional info based on media type
                      Text(
                        _getMediaDurationText(controller),
                        style: textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),

                  // Rating stars
                  SizedBox(height: isSmallScreen ? 8.0 : 12.0),
                  Row(
                    children: [
                      RatingStars(
                        rating: item?.averageRating ?? 0,
                        size: isSmallScreen ? 16.0 : 20.0,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${item?.averageRating.toStringAsFixed(1) ?? '0.0'} (${item?.reviewCount ?? 0} reviews)',
                        style: textTheme.bodySmall?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Quick stats section
  Widget _buildQuickStats(
    BuildContext context,
    MediaDetailsController controller,
  ) {
    final textTheme = Theme.of(context).textTheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 360;
    final mediaType = controller.mediaType.value;

    // Determine stats based on media type
    List<Map<String, dynamic>> getStats() {
      switch (mediaType) {
        case 'movie':
          final movie = controller.mediaItem.value as dynamic;
          return [
            {
              'icon': Icons.person_outline,
              'title': 'Director',
              'value': movie?.director ?? 'Unknown',
            },
            {
              'icon': Icons.timer_outlined,
              'title': 'Duration',
              'value':
                  movie?.durationMinutes != null
                      ? '${movie!.durationMinutes} min'
                      : 'Unknown',
            },
            {
              'icon': Icons.calendar_today_outlined,
              'title': 'Released',
              'value':
                  movie?.releaseDate != null
                      ? DateFormat('MMM d, yyyy').format(movie!.releaseDate)
                      : 'Unknown',
            },
          ];
        case 'teledrama':
          final teledrama = controller.mediaItem.value as dynamic;
          return [
            {
              'icon': Icons.tv_outlined,
              'title': 'Network',
              'value': teledrama?.network ?? 'Unknown',
            },
            {
              'icon': Icons.view_carousel_outlined,
              'title': 'Seasons',
              'value': '${teledrama?.seasons ?? 0}',
            },
            {
              'icon': Icons.video_library_outlined,
              'title': 'Episodes',
              'value': '${teledrama?.episodes ?? 0}',
            },
          ];
        case 'song':
          final song = controller.mediaItem.value as dynamic;
          return [
            {
              'icon': Icons.person_outline,
              'title': 'Artist',
              'value': song?.artist ?? 'Unknown',
            },
            {
              'icon': Icons.album_outlined,
              'title': 'Album',
              'value': song?.album ?? 'Single',
            },
            {
              'icon': Icons.timer_outlined,
              'title': 'Duration',
              'value':
                  song?.durationSeconds != null
                      ? _formatDuration(song!.durationSeconds)
                      : 'Unknown',
            },
          ];
        case 'book':
          final book = controller.mediaItem.value as dynamic;
          return [
            {
              'icon': Icons.person_outline,
              'title': 'Author',
              'value': book?.author ?? 'Unknown',
            },
            {
              'icon': Icons.business_outlined,
              'title': 'Publisher',
              'value': book?.publisher ?? 'Unknown',
            },
            {
              'icon': Icons.book_outlined,
              'title': 'Pages',
              'value': '${book?.pages ?? 0}',
            },
          ];
        default:
          return [
            {
              'icon': Icons.calendar_today_outlined,
              'title': 'Released',
              'value':
                  controller.mediaItem.value?.releaseDate != null
                      ? DateFormat(
                        'MMM d, yyyy',
                      ).format(controller.mediaItem.value!.releaseDate)
                      : 'Unknown',
            },
          ];
      }
    }

    final stats = getStats();

    return Container(
      margin: EdgeInsets.symmetric(
        vertical: isSmallScreen ? 12.0 : 16.0,
        horizontal: isSmallScreen ? 12.0 : 16.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children:
            stats.map((stat) {
              return Expanded(
                child: Column(
                  children: [
                    Icon(
                      stat['icon'] as IconData,
                      color: Colors.white70,
                      size: isSmallScreen ? 20.0 : 24.0,
                    ),
                    SizedBox(height: isSmallScreen ? 4.0 : 6.0),
                    Text(
                      stat['title'] as String,
                      style: textTheme.labelSmall?.copyWith(
                        color: Colors.white54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 2.0 : 4.0),
                    Text(
                      stat['value'] as String,
                      style: textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            }).toList(),
      ),
    );
  }

  // Description section
  Widget _buildDescription(
    BuildContext context,
    MediaDetailsController controller,
  ) {
    final textTheme = Theme.of(context).textTheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 360;
    final item = controller.mediaItem.value;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12.0 : 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Description',
            style: textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: isSmallScreen ? 8.0 : 12.0),
          Obx(
            () => Text(
              item?.description ?? '',
              style: textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
                height: 1.5,
              ),
              maxLines: controller.showFullDescription.value ? null : 3,
              overflow:
                  controller.showFullDescription.value
                      ? TextOverflow.visible
                      : TextOverflow.ellipsis,
            ),
          ),
          TextButton(
            onPressed: () => controller.toggleDescription(),
            child: Text(
              controller.showFullDescription.value ? 'Show Less' : 'Read More',
              style: textTheme.labelMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Genres
          SizedBox(height: isSmallScreen ? 8.0 : 12.0),
          Text(
            'Genres',
            style: textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: isSmallScreen ? 8.0 : 12.0),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                (item?.genres ?? []).map((genre) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      genre,
                      style: textTheme.labelSmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
          ),
          SizedBox(height: isSmallScreen ? 16.0 : 24.0),
        ],
      ),
    );
  }

  // Media type specific details
  Widget _buildMediaSpecificDetails(
    BuildContext context,
    MediaDetailsController controller,
  ) {
    final textTheme = Theme.of(context).textTheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 360;
    final mediaType = controller.mediaType.value;
    final item = controller.mediaItem.value;

    Widget content;

    switch (mediaType) {
      case 'movie':
        final movie = item as dynamic;
        content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cast section
            Text(
              'Cast',
              style: textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: isSmallScreen ? 8.0 : 12.0),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: movie?.cast?.length ?? 0,
                itemBuilder: (context, index) {
                  final actor = movie?.cast[index] ?? '';
                  return Container(
                    width: 80,
                    margin: const EdgeInsets.only(right: 12),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.grey[800],
                          child: const Icon(
                            Icons.person,
                            color: Colors.white54,
                            size: 30,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          actor,
                          style: textTheme.bodySmall?.copyWith(
                            color: Colors.white70,
                          ),
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
        break;

      case 'teledrama':
        final teledrama = item as dynamic;
        content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cast section
            Text(
              'Cast',
              style: textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: isSmallScreen ? 8.0 : 12.0),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: teledrama?.cast?.length ?? 0,
                itemBuilder: (context, index) {
                  final actor = teledrama?.cast[index] ?? '';
                  return Container(
                    width: 80,
                    margin: const EdgeInsets.only(right: 12),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.grey[800],
                          child: const Icon(
                            Icons.person,
                            color: Colors.white54,
                            size: 30,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          actor,
                          style: textTheme.bodySmall?.copyWith(
                            color: Colors.white70,
                          ),
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
        break;

      case 'song':
        final song = item as dynamic;
        content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Featuring artists
            if (song?.featuring?.isNotEmpty == true)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Featuring',
                    style: textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 8.0 : 12.0),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        (song?.featuring ?? []).map<Widget>((artist) {
                          return Chip(
                            label: Text(artist),
                            backgroundColor: Colors.grey[800],
                            labelStyle: textTheme.bodySmall?.copyWith(
                              color: Colors.white,
                            ),
                            avatar: const CircleAvatar(
                              backgroundColor: Colors.transparent,
                              child: Icon(
                                Icons.person,
                                color: Colors.white54,
                                size: 16,
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                  SizedBox(height: isSmallScreen ? 16.0 : 24.0),
                ],
              ),

            // Audio player placeholder
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.purple,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Preview Available',
                          style: textTheme.bodyMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tap to play a 30-second preview',
                          style: textTheme.bodySmall?.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
        break;

      case 'book':
        final book = item as dynamic;
        content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ISBN
            Text(
              'Details',
              style: textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: isSmallScreen ? 8.0 : 12.0),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  _buildInfoRow(context, 'ISBN', book?.isbn ?? 'N/A'),
                  const Divider(color: Colors.grey),
                  _buildInfoRow(
                    context,
                    'Publisher',
                    book?.publisher ?? 'Unknown',
                  ),
                  const Divider(color: Colors.grey),
                  _buildInfoRow(context, 'Pages', '${book?.pages ?? 0} pages'),
                  const Divider(color: Colors.grey),
                  _buildInfoRow(
                    context,
                    'Published',
                    book?.releaseDate != null
                        ? DateFormat('MMMM d, yyyy').format(book!.releaseDate)
                        : 'Unknown',
                  ),
                ],
              ),
            ),
          ],
        );
        break;

      default:
        content = const SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 12.0 : 16.0,
        vertical: isSmallScreen ? 8.0 : 12.0,
      ),
      child: content,
    );
  }

  // Helper for book details
  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: textTheme.bodyMedium?.copyWith(color: Colors.white70),
          ),
          Text(
            value,
            style: textTheme.bodyMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Reviews section
  Widget _buildReviewsSection(
    BuildContext context,
    MediaDetailsController controller,
  ) {
    final textTheme = Theme.of(context).textTheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 360;

    return Container(
      margin: EdgeInsets.only(
        top: isSmallScreen ? 16.0 : 24.0,
        bottom: isSmallScreen ? 80.0 : 100.0, // Space for FAB
      ),
      padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12.0 : 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Reviews header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Reviews',
                style: textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Obx(
                () => TextButton(
                  onPressed: () => controller.toggleReviewDisplay(),
                  child: Text(
                    controller.showAllReviews.value
                        ? 'Show Top Reviews'
                        : 'Show All Reviews',
                    style: textTheme.labelMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 8.0 : 12.0),

          // Reviews list
          Obx(() {
            if (controller.isLoadingReviews.value) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              );
            }

            if (controller.reviews.isEmpty) {
              return _buildEmptyReviews(context);
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.displayedReviews.length,
              itemBuilder: (context, index) {
                final review = controller.displayedReviews[index];
                return _buildReviewItem(context, controller, review);
              },
            );
          }),
        ],
      ),
    );
  }

  // Empty reviews state
  Widget _buildEmptyReviews(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(24),
      alignment: Alignment.center,
      child: Column(
        children: [
          const Icon(
            Icons.rate_review_outlined,
            color: Colors.white30,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'No reviews yet',
            style: textTheme.titleMedium?.copyWith(
              color: Colors.white70,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Be the first to share your thoughts',
            style: textTheme.bodyMedium?.copyWith(color: Colors.white54),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Review item
  Widget _buildReviewItem(
    BuildContext context,
    MediaDetailsController controller,
    Review review,
  ) {
    final textTheme = Theme.of(context).textTheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 360;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Review header with user info
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // User avatar
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey[800],
                backgroundImage:
                    review.userProfileImage != null
                        ? NetworkImage(review.userProfileImage!)
                        : null,
                child:
                    review.userProfileImage == null
                        ? const Icon(
                          Icons.person,
                          color: Colors.white54,
                          size: 24,
                        )
                        : null,
              ),
              const SizedBox(width: 12),

              // User name and review date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userFullName,
                      style: textTheme.titleSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      DateFormat('MMM d, yyyy').format(review.createdAt),
                      style: textTheme.bodySmall?.copyWith(
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),
              ),

              // Rating
              RatingStars(rating: review.rating, size: 16),
            ],
          ),

          // Review content
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              review.content,
              style: textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
                height: 1.4,
              ),
            ),
          ),

          // Review actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Like button
              Row(
                children: [
                  IconButton(
                    onPressed: () => controller.likeReview(review.id),
                    icon: Icon(
                      Icons.thumb_up_alt_outlined,
                      color:
                          controller.userLikedReviews.contains(review.id)
                              ? AppColors.primary
                              : Colors.white54,
                      size: 18,
                    ),
                    visualDensity: VisualDensity.compact,
                    splashRadius: 20,
                  ),
                  Text(
                    review.likeCount.toString(),
                    style: textTheme.bodySmall?.copyWith(color: Colors.white54),
                  ),
                ],
              ),

              // Comment button
              TextButton.icon(
                onPressed: () => controller.toggleComments(review.id),
                icon: const Icon(Icons.comment_outlined, size: 18),
                label: Text('${review.commentCount} Comments'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white54,
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),

          // Comments section
          Obx(
            () =>
                controller.expandedReviews.contains(review.id)
                    ? _buildCommentsSection(context, controller, review)
                    : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  // Comments section for a review
  Widget _buildCommentsSection(
    BuildContext context,
    MediaDetailsController controller,
    Review review,
  ) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(color: Colors.grey),

        // Comments list
        Obx(() {
          final comments = controller.getCommentsForReview(review.id);

          if (controller.isLoadingComments.value) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                  strokeWidth: 2,
                ),
              ),
            );
          }

          if (comments.isEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'No comments yet',
                style: textTheme.bodySmall?.copyWith(
                  color: Colors.white54,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            );
          }

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: comments.length,
            itemBuilder: (context, index) {
              return _buildCommentItem(context, controller, comments[index]);
            },
          );
        }),

        // Add comment input
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.grey[800],
                child: const Icon(
                  Icons.person,
                  color: Colors.white54,
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: controller.getCommentController(review.id),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Add a comment...',
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(
                        color: Colors.grey.withOpacity(0.3),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(
                        color: Colors.grey.withOpacity(0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => controller.submitComment(review.id, null),
                icon: const Icon(Icons.send_rounded, color: AppColors.primary),
                visualDensity: VisualDensity.compact,
                splashRadius: 20,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Individual comment item
  Widget _buildCommentItem(
    BuildContext context,
    MediaDetailsController controller,
    Comment comment,
  ) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.only(
        top: 12,
        bottom: 8,
        left: comment.parentId != null ? 32 : 0, // Indent replies
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User avatar
              CircleAvatar(
                radius: 14,
                backgroundColor: Colors.grey[800],
                backgroundImage:
                    comment.userProfileImage != null
                        ? NetworkImage(comment.userProfileImage!)
                        : null,
                child:
                    comment.userProfileImage == null
                        ? const Icon(
                          Icons.person,
                          color: Colors.white54,
                          size: 16,
                        )
                        : null,
              ),
              const SizedBox(width: 8),

              // Comment content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User name and comment date
                    Row(
                      children: [
                        Text(
                          comment.userFullName,
                          style: textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('MMM d, yyyy').format(comment.createdAt),
                          style: textTheme.bodySmall?.copyWith(
                            color: Colors.white54,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Comment text
                    Text(
                      comment.content,
                      style: textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                      ),
                    ),

                    // Comment actions
                    Row(
                      children: [
                        // Like button
                        TextButton.icon(
                          onPressed: () => controller.likeComment(comment.id),
                          icon: Icon(
                            Icons.thumb_up_alt_outlined,
                            color:
                                controller.userLikedComments.contains(
                                      comment.id,
                                    )
                                    ? AppColors.primary
                                    : Colors.white54,
                            size: 12,
                          ),
                          label: Text(
                            comment.likeCount.toString(),
                            style: textTheme.bodySmall?.copyWith(
                              color: Colors.white54,
                              fontSize: 10,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                          ),
                        ),

                        // Reply button
                        TextButton(
                          onPressed: () => controller.setReplyTo(comment),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                          ),
                          child: Text(
                            'Reply',
                            style: textTheme.bodySmall?.copyWith(
                              color: Colors.white54,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Reply input if active
                    Obx(
                      () =>
                          controller.replyingToComment.value?.id == comment.id
                              ? Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: controller.replyController,
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                        decoration: InputDecoration(
                                          hintText:
                                              'Reply to ${comment.userFullName}...',
                                          hintStyle: TextStyle(
                                            color: Colors.grey.shade400,
                                          ),
                                          isDense: true,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 8,
                                              ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            borderSide: BorderSide(
                                              color: Colors.grey.withOpacity(
                                                0.3,
                                              ),
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            borderSide: BorderSide(
                                              color: Colors.grey.withOpacity(
                                                0.3,
                                              ),
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            borderSide: const BorderSide(
                                              color: AppColors.primary,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () => controller.submitReply(),
                                      icon: const Icon(
                                        Icons.send_rounded,
                                        color: AppColors.primary,
                                        size: 18,
                                      ),
                                      visualDensity: VisualDensity.compact,
                                      splashRadius: 18,
                                    ),
                                    IconButton(
                                      onPressed: () => controller.cancelReply(),
                                      icon: const Icon(
                                        Icons.close_rounded,
                                        color: Colors.white54,
                                        size: 18,
                                      ),
                                      visualDensity: VisualDensity.compact,
                                      splashRadius: 18,
                                    ),
                                  ],
                                ),
                              )
                              : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Show child comments (replies) if any
          Obx(() {
            final replies = controller.getRepliesForComment(comment.id);
            if (replies.isNotEmpty) {
              return Column(
                children:
                    replies.map((reply) {
                      return _buildCommentItem(context, controller, reply);
                    }).toList(),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  // Helpers
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

  String _getMediaDurationText(MediaDetailsController controller) {
    final mediaType = controller.mediaType.value;
    final item = controller.mediaItem.value;

    switch (mediaType) {
      case 'movie':
        final movie = item as dynamic;
        return movie?.durationMinutes != null
            ? '${movie!.durationMinutes} min'
            : 'Unknown duration';
      case 'teledrama':
        final teledrama = item as dynamic;
        return '${teledrama?.seasons ?? 0} ${teledrama?.seasons == 1 ? 'Season' : 'Seasons'}';
      case 'song':
        final song = item as dynamic;
        return song?.durationSeconds != null
            ? _formatDuration(song!.durationSeconds)
            : 'Unknown length';
      case 'book':
        final book = item as dynamic;
        return '${book?.pages ?? 0} pages';
      default:
        return '';
    }
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
