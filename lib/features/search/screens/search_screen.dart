import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/search_controller.dart';
import '../widgets/search_result_item.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Put controller with permanent true to prevent disposal issues
    final controller = Get.put(SimpleSearchController(), permanent: true);
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 360;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            // Search header with back button and search field
            _buildSearchHeader(context, controller, isSmallScreen),

            // Category filter buttons
            _buildCategoryFilter(context, controller, isSmallScreen),

            // Search results
            Expanded(
              child: GetBuilder<SimpleSearchController>(
                init: controller,
                builder: (controller) {
                  if (controller.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    );
                  }

                  if (!controller.hasSearched) {
                    // Show empty state with search instructions when no search has been performed
                    return _buildInitialState(context);
                  }

                  if (controller.searchResults.isEmpty &&
                      controller.hasSearched) {
                    return _buildEmptyState(context);
                  }

                  return ListView.builder(
                    padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
                    itemCount: controller.searchResults.length,
                    itemBuilder: (context, index) {
                      final item = controller.searchResults[index];
                      return SearchResultItem(
                        item: item,
                        onTap: () {
                          // Navigate to details screen
                          Get.toNamed(
                            '/media-details',
                            arguments: {'id': item.id, 'type': item.type},
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Search header with back button and search field
  Widget _buildSearchHeader(
    BuildContext context,
    SimpleSearchController controller,
    bool isSmallScreen,
  ) {
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
      child: Row(
        children: [
          // Search field
          Expanded(
            child: Container(
              height: isSmallScreen ? 42.0 : 48.0,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: TextField(
                controller: controller.searchController,
                onChanged: (value) {
                  controller.performSearch(value);
                },
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search media...',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: Colors.grey,
                  ),
                  suffixIcon: GetBuilder<SimpleSearchController>(
                    init: controller,
                    builder:
                        (ctrl) =>
                            ctrl.searchController.text.isNotEmpty
                                ? IconButton(
                                  onPressed: () {
                                    ctrl.searchController.clear();
                                    ctrl.clearSearch();
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
          ),
        ],
      ),
    );
  }

  // Category filter buttons
  Widget _buildCategoryFilter(
    BuildContext context,
    SimpleSearchController controller,
    bool isSmallScreen,
  ) {
    return Container(
      height: isSmallScreen ? 40.0 : 45.0,
      padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 10.0 : 15.0),
      margin: EdgeInsets.only(top: isSmallScreen ? 6.0 : 8.0),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: controller.categories.length,
        itemBuilder: (context, index) {
          final category = controller.categories[index];
          return GetBuilder<SimpleSearchController>(
            init: controller,
            builder:
                (ctrl) => GestureDetector(
                  onTap: () => ctrl.updateCategoryFilter(category),
                  child: Container(
                    margin: EdgeInsets.only(right: isSmallScreen ? 8.0 : 12.0),
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 12.0 : 16.0,
                      vertical: isSmallScreen ? 6.0 : 8.0,
                    ),
                    decoration: BoxDecoration(
                      color:
                          ctrl.selectedCategory == category
                              ? AppColors.primary
                              : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color:
                            ctrl.selectedCategory == category
                                ? AppColors.primary
                                : Colors.grey.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      category,
                      style: TextStyle(
                        color:
                            ctrl.selectedCategory == category
                                ? Colors.white
                                : Colors.grey.shade300,
                        fontWeight:
                            ctrl.selectedCategory == category
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

  // Initial state when no search has been performed
  Widget _buildInitialState(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_rounded,
            color: Colors.grey.withOpacity(0.5),
            size: 80,
          ),
          const SizedBox(height: 16),
          Text(
            'Search Media',
            style: textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48.0),
            child: Text(
              'Enter a title, artist, author, or director name to find media',
              style: textTheme.bodyMedium?.copyWith(
                color: Colors.grey.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  // Empty state when no results are found
  Widget _buildEmptyState(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            color: Colors.grey.withOpacity(0.5),
            size: 80,
          ),
          const SizedBox(height: 16),
          Text(
            'No results found',
            style: textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try different keywords or categories',
            style: textTheme.bodyMedium?.copyWith(
              color: Colors.grey.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}
