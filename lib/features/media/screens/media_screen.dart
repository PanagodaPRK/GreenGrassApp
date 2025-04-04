import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/media_controller.dart';
import '../widgets/media_card.dart';

class MediaScreen extends StatelessWidget {
  const MediaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final MediaController controller = Get.put(MediaController());
    final textTheme = Theme.of(context).textTheme;

    // Get screen dimensions for responsive layout
    final screenWidth = MediaQuery.of(context).size.width;

    // Apply system UI overlay style for a more immersive experience
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            // Header with search bar
            _buildHeader(context, controller),

            // Category filter tabs
            _buildCategoryFilter(context, controller),

            // Main content
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primary,
                backgroundColor: AppColors.surfaceDark,
                onRefresh: () => controller.loadAllMedia(),
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return _buildLoadingIndicator();
                  }

                  if (controller.hasError.value) {
                    return _buildErrorWidget(controller);
                  }

                  if (controller.displayedMedia.isEmpty) {
                    return _buildEmptyState(
                      context,
                      controller.selectedMediaType.value,
                    );
                  }

                  return _buildMediaGrid(context, controller, screenWidth);
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Header with search bar and title
  Widget _buildHeader(BuildContext context, MediaController controller) {
    final textTheme = Theme.of(context).textTheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final TextEditingController textController = TextEditingController();
    final bool isSmallScreen = screenWidth < 360;

    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'Media',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      fontSize: isSmallScreen ? 20.0 : 24.0,
                    ),
                  ),
                  Text(
                    'Library',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w400,
                      color: Colors.white70,
                      fontSize: isSmallScreen ? 20.0 : 24.0,
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(
                  Icons.arrow_back_ios_rounded,
                  color: Colors.white70,
                  size: 20,
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 12.0 : 16.0),

          // Search bar
          Container(
            height: isSmallScreen ? 42.0 : 48.0,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withOpacity(0.3), width: 1),
            ),
            child: TextField(
              controller: textController,
              onChanged: (value) {
                controller.updateSearchQuery(value);
              },
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search media...',
                hintStyle: TextStyle(color: Colors.grey.shade400),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: Colors.grey,
                ),
                suffixIcon: Obx(
                  () =>
                      controller.searchQuery.isNotEmpty
                          ? IconButton(
                            onPressed: () {
                              controller.updateSearchQuery('');
                              textController.clear();
                            },
                            icon: const Icon(
                              Icons.close_rounded,
                              color: Colors.grey,
                              size: 20,
                            ),
                            splashRadius: 16,
                          )
                          : const SizedBox.shrink(),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 12.0 : 16.0,
                  vertical: isSmallScreen ? 8.0 : 10.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Category filter tabs
  Widget _buildCategoryFilter(
    BuildContext context,
    MediaController controller,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 360;

    return Container(
      height: isSmallScreen ? 40.0 : 45.0,
      padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 10.0 : 15.0),
      margin: EdgeInsets.only(top: isSmallScreen ? 6.0 : 8.0),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: controller.mediaTypes.length,
        itemBuilder: (context, index) {
          final category = controller.mediaTypes[index];
          return Obx(
            () => GestureDetector(
              onTap: () => controller.changeMediaType(category),
              child: Container(
                margin: EdgeInsets.only(right: isSmallScreen ? 8.0 : 12.0),
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 12.0 : 16.0,
                  vertical: isSmallScreen ? 6.0 : 8.0,
                ),
                decoration: BoxDecoration(
                  color:
                      controller.selectedMediaType.value == category
                          ? AppColors.primary
                          : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color:
                        controller.selectedMediaType.value == category
                            ? AppColors.primary
                            : Colors.grey.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  category,
                  style: TextStyle(
                    color:
                        controller.selectedMediaType.value == category
                            ? Colors.white
                            : Colors.grey.shade300,
                    fontWeight:
                        controller.selectedMediaType.value == category
                            ? FontWeight.bold
                            : FontWeight.normal,
                    fontSize: isSmallScreen ? 12.0 : 14.0,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Media grid with pagination - adjusted for taller cards
  Widget _buildMediaGrid(
    BuildContext context,
    MediaController controller,
    double screenWidth,
  ) {
    // Determine grid properties based on screen width
    int crossAxisCount;
    double childAspectRatio;
    double horizontalPadding;
    double gridSpacing;

    if (screenWidth < 360) {
      // Small phones
      crossAxisCount = 1;
      childAspectRatio = 0.65;
      horizontalPadding = 12.0;
      gridSpacing = 16.0;
    } else if (screenWidth < 600) {
      // Regular phones
      crossAxisCount = 2;
      childAspectRatio = 0.65;
      horizontalPadding = 16.0;
      gridSpacing = 16.0;
    } else if (screenWidth < 900) {
      // Tablets
      crossAxisCount = 3;
      childAspectRatio = 0.6;
      horizontalPadding = 20.0;
      gridSpacing = 20.0;
    } else {
      // Large tablets and desktops
      crossAxisCount = 4;
      childAspectRatio = 0.58;
      horizontalPadding = 24.0;
      gridSpacing = 24.0;
    }

    return Column(
      children: [
        // Media grid
        Expanded(
          child: GridView.builder(
            padding: EdgeInsets.all(horizontalPadding),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: childAspectRatio, // Adjusted for taller cards
              crossAxisSpacing: gridSpacing,
              mainAxisSpacing: gridSpacing,
            ),
            itemCount: controller.displayedMedia.length,
            itemBuilder: (context, index) {
              final item = controller.displayedMedia[index];
              final type = controller.getMediaTypeFromItem(item);
              final title = controller.getTitleFromItem(item);
              final subtitle = controller.getSubtitleFromItem(item);
              final imageUrl = controller.getImageFromItem(item);
              final rating = controller.getRatingFromItem(item);
              final genres = controller.getGenresFromItem(item);
              final id = item.id;

              return MediaCard(
                item: item,
                type: type,
                title: title,
                subtitle: subtitle,
                imageUrl: imageUrl,
                rating: rating,
                genres: genres,
                id: id,
              );
            },
          ),
        ),

        // Pagination controls
        Obx(
          () =>
              controller.totalPages.value > 1
                  ? Container(
                    padding: EdgeInsets.all(screenWidth < 360 ? 12.0 : 16.0),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDark,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 6,
                          offset: const Offset(0, -3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Previous page button
                        _buildPaginationButton(
                          onPressed:
                              controller.currentPage.value > 1
                                  ? () => controller.previousPage()
                                  : null,
                          icon: Icons.keyboard_arrow_left_rounded,
                        ),
                        SizedBox(width: screenWidth < 360 ? 12.0 : 16.0),

                        // Page indicator
                        Text(
                          'Page ${controller.currentPage.value} of ${controller.totalPages.value}',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: screenWidth < 360 ? 12.0 : 14.0,
                          ),
                        ),

                        SizedBox(width: screenWidth < 360 ? 12.0 : 16.0),

                        // Next page button
                        _buildPaginationButton(
                          onPressed:
                              controller.currentPage.value <
                                      controller.totalPages.value
                                  ? () => controller.nextPage()
                                  : null,
                          icon: Icons.keyboard_arrow_right_rounded,
                        ),
                      ],
                    ),
                  )
                  : const SizedBox.shrink(),
        ),
      ],
    );
  }

  // Pagination button
  Widget _buildPaginationButton({
    required VoidCallback? onPressed,
    required IconData icon,
  }) {
    return Material(
      color:
          onPressed != null
              ? AppColors.primary.withOpacity(0.2)
              : Colors.grey.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Icon(
            icon,
            color: onPressed != null ? AppColors.primary : Colors.grey.shade600,
          ),
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

  // Error widget
  Widget _buildErrorWidget(MediaController controller) {
    final screenWidth = MediaQuery.of(Get.context!).size.width;
    final bool isSmallScreen = screenWidth < 360;

    return Center(
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
            'Unable to load media',
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
            onPressed: () => controller.loadAllMedia(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  // Empty state widget
  Widget _buildEmptyState(BuildContext context, String mediaType) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 360;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.movie_filter_outlined,
            color: Colors.white.withOpacity(0.5),
            size: isSmallScreen ? 64 : 80,
          ),
          SizedBox(height: isSmallScreen ? 12.0 : 16.0),
          Text(
            'No $mediaType found',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: isSmallScreen ? 16.0 : 18.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: isSmallScreen ? 6.0 : 8.0),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 24.0 : 32.0,
            ),
            child: Text(
              'Try adjusting your search or selecting a different category',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: isSmallScreen ? 12.0 : 14.0,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
