import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'home_controller.dart';
import '../../theme/app_theme.dart';
import '../../../routes/app_routes.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());
    final PageController pageController = PageController();

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: const Text(
          'Explore Events',
          style: TextStyle(
            color: AppColors.primaryDark,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primaryDark),
            onPressed: controller.fetchData,
          ),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.secondaryBlue),
            );
          }

          if (controller.events.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_busy, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'No events found',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            );
          }

          final featuredList = controller.featuredEvents;
          final categories = controller.categoryNames;
          final otherList = controller.otherEvents;

          return RefreshIndicator(
            onRefresh: controller.fetchData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Featured Events Carousel (PageView) at the Top
                  if (featuredList.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: PageView.builder(
                        controller: pageController,
                        onPageChanged: (idx) => controller.featuredPageIndex.value = idx,
                        itemCount: featuredList.length,
                        itemBuilder: (context, index) {
                          final event = featuredList[index];
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.12),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Stack(
                                children: [
                                  // Background Image
                                  Positioned.fill(
                                    child: event.imageUrl != null && event.imageUrl!.isNotEmpty
                                        ? Image.network(
                                            event.imageUrl!,
                                            fit: BoxFit.cover,
                                          )
                                        : Container(
                                            color: AppColors.primaryDark,
                                            child: const Icon(
                                              Icons.image_outlined,
                                              size: 64,
                                              color: Colors.white24,
                                            ),
                                          ),
                                  ),
                                  // Dark Gradient Overlay
                                  Positioned.fill(
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.bottomCenter,
                                          end: Alignment.topCenter,
                                          colors: [
                                            Colors.black.withOpacity(0.75),
                                            Colors.black.withOpacity(0.1),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Event Title & Book Now Button
                                  Positioned(
                                    left: 20,
                                    bottom: 20,
                                    right: 20,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          event.title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        ElevatedButton(
                                          onPressed: () => Get.toNamed(
                                            AppRoutes.eventDetail,
                                            arguments: event.id,
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.secondaryBlue,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(16),
                                            ),
                                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                                            elevation: 0,
                                          ),
                                          child: const Text(
                                            'Book Now',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
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
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Dot Page Indicators
                    Obx(() => Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            featuredList.length,
                            (index) => Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: controller.featuredPageIndex.value == index ? 10 : 7,
                              height: controller.featuredPageIndex.value == index ? 10 : 7,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: controller.featuredPageIndex.value == index
                                    ? AppColors.secondaryBlue
                                    : Colors.grey.shade400,
                              ),
                            ),
                          ),
                        )),
                  ],

                  // 2. Section Header: Trending & See All Button
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16, top: 20, bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Trending',
                          style: TextStyle(
                            color: AppColors.primaryDark,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        TextButton(
                          onPressed: () => Get.toNamed(
                            AppRoutes.eventList,
                            arguments: controller.selectedCategory.value,
                          ),
                          child: const Text(
                            'See All',
                            style: TextStyle(
                              color: AppColors.secondaryBlue,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 3. Category Horizontal Filter Selector List
                  SizedBox(
                    height: 42,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final catName = categories[index];
                        final isSelected = controller.selectedCategory.value == catName;

                        return GestureDetector(
                          onTap: () => controller.selectedCategory.value = catName,
                          child: Container(
                            margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.secondaryBlue : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected ? Colors.transparent : Colors.grey.shade300,
                                width: 1.2,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                catName,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.grey.shade600,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 4. Trending/Other Events Horizontal List below it
                  SizedBox(
                    height: 295,
                    child: otherList.isEmpty
                        ? Center(
                            child: Text(
                              'No events',
                              style: TextStyle(color: Colors.grey.shade500),
                            ),
                          )
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: otherList.length,
                            itemBuilder: (context, index) {
                              final event = otherList[index];
                              return GestureDetector(
                                onTap: () => Get.toNamed(
                                  AppRoutes.eventDetail,
                                  arguments: event.id,
                                ),
                                child: Container(
                                  width: 235,
                                  margin: const EdgeInsets.only(right: 16, bottom: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.04),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Image Stack with Date Tag
                                      Stack(
                                        children: [
                                          ClipRRect(
                                            borderRadius: const BorderRadius.vertical(
                                              top: Radius.circular(20),
                                            ),
                                            child: Container(
                                              height: 125,
                                              width: double.infinity,
                                              color: Colors.blue.shade50,
                                              child: event.imageUrl != null && event.imageUrl!.isNotEmpty
                                                  ? Image.network(
                                                      event.imageUrl!,
                                                      fit: BoxFit.cover,
                                                    )
                                                  : const Icon(
                                                      Icons.image_outlined,
                                                      size: 40,
                                                      color: AppColors.secondaryBlue,
                                                    ),
                                            ),
                                          ),
                                          Positioned(
                                            top: 10,
                                            right: 10,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(0.95),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    DateFormat('dd').format(event.date),
                                                    style: const TextStyle(
                                                      color: AppColors.accentCoral,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                  Text(
                                                    DateFormat('MMM').format(event.date).toUpperCase(),
                                                    style: const TextStyle(
                                                      color: AppColors.primaryDark,
                                                      fontWeight: FontWeight.w700,
                                                      fontSize: 10,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                      // Card Details Info
                                      Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              event.title,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                color: AppColors.primaryDark,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                if (event.category != null)
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 2,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: AppColors.secondaryBlue.withOpacity(0.12),
                                                      borderRadius: BorderRadius.circular(6),
                                                    ),
                                                    child: Text(
                                                      event.category!.name,
                                                      style: const TextStyle(
                                                        color: AppColors.secondaryBlue,
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 11,
                                                      ),
                                                    ),
                                                  ),
                                                const Spacer(),
                                                // Mock overlaps of circles
                                                SizedBox(
                                                  width: 35,
                                                  height: 16,
                                                  child: Stack(
                                                    children: [
                                                      Positioned(
                                                        left: 0,
                                                        child: CircleAvatar(
                                                          radius: 8,
                                                          backgroundColor: Colors.blue.shade300,
                                                        ),
                                                      ),
                                                      Positioned(
                                                        left: 8,
                                                        child: CircleAvatar(
                                                          radius: 8,
                                                          backgroundColor: Colors.orange.shade300,
                                                        ),
                                                      ),
                                                      Positioned(
                                                        left: 16,
                                                        child: CircleAvatar(
                                                          radius: 8,
                                                          backgroundColor: Colors.red.shade300,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '20K+',
                                                  style: TextStyle(
                                                    color: Colors.grey.shade600,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 10),
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.location_on_outlined,
                                                  size: 14,
                                                  color: AppColors.secondaryBlue,
                                                ),
                                                const SizedBox(width: 4),
                                                Expanded(
                                                  child: Text(
                                                    event.location,
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      color: Colors.grey.shade600,
                                                      fontSize: 11,
                                                    ),
                                                  ),
                                                ),
                                                const Icon(
                                                  Icons.bookmark_border_rounded,
                                                  size: 16,
                                                  color: AppColors.secondaryBlue,
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
