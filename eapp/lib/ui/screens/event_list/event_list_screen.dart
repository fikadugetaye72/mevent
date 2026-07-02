import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'event_list_controller.dart';
import '../../theme/app_theme.dart';
import '../../../routes/app_routes.dart';

class EventListScreen extends StatelessWidget {
  const EventListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EventListController());

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ሁሉም ዝግጅቶች (All Events)',
          style: TextStyle(
            color: AppColors.primaryDark,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryDark),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Horizontal Categories Selector at the Top
            Container(
              height: 60,
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              color: Colors.white,
              child: Obx(() {
                final categories = controller.categoryNames;
                return ListView.builder(
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
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
            const SizedBox(height: 8),

            // Top-to-Down Vertical List
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.secondaryBlue));
                }

                final list = controller.filteredEvents;
                if (list.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.calendar_today_outlined, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          'ከዚህ ዘርፍ ምንም ዝግጅት አልተገኘም (No events found)',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: controller.fetchEvents,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final event = list[index];
                      final dateStr = DateFormat('MMM dd, yyyy').format(event.date);
                      final timeStr = DateFormat('hh:mm a').format(event.date);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        clipBehavior: Clip.antiAlias,
                        elevation: 1.5,
                        color: Colors.white,
                        child: InkWell(
                          onTap: () => Get.toNamed(
                            AppRoutes.eventDetail,
                            arguments: event.id,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Event Image Thumbnail
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    width: 110,
                                    height: 100,
                                    color: Colors.blue.shade50,
                                    child: event.imageUrl != null && event.imageUrl!.isNotEmpty
                                        ? Image.network(
                                            event.imageUrl!,
                                            fit: BoxFit.cover,
                                          )
                                        : const Icon(
                                            Icons.image_outlined,
                                            size: 36,
                                            color: AppColors.secondaryBlue,
                                          ),
                                  ),
                                ),
                                const SizedBox(width: 14),

                                // Event Details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        event.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: AppColors.primaryDark,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      
                                      // Category & Date Info
                                      Row(
                                        children: [
                                          if (event.category != null)
                                            Container(
                                              margin: const EdgeInsets.only(right: 8),
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: AppColors.accentCoral.withOpacity(0.12),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                event.category!.name,
                                                style: const TextStyle(
                                                  color: AppColors.accentCoral,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          Icon(Icons.calendar_month, size: 13, color: Colors.grey.shade600),
                                          const SizedBox(width: 3),
                                          Text(
                                            '$dateStr - $timeStr',
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontSize: 11.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),

                                      // Location Address
                                      Row(
                                        children: [
                                          const Icon(Icons.location_on_rounded, size: 14, color: AppColors.secondaryBlue),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              event.location,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: Colors.grey.shade600,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),

                                      // Pricing
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            event.price == null || event.price == 0 
                                                ? 'Free / ነፃ' 
                                                : '\$${event.price!.toStringAsFixed(1)}',
                                            style: const TextStyle(
                                              color: AppColors.secondaryBlue,
                                              fontWeight: FontWeight.w800,
                                              fontSize: 13.5,
                                            ),
                                          ),
                                          if (event.vipPrice != null)
                                            Text(
                                              'VIP: \$${event.vipPrice!.toStringAsFixed(1)}',
                                              style: const TextStyle(
                                                color: AppColors.accentCoral,
                                                fontWeight: FontWeight.w800,
                                                fontSize: 13.5,
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
                        ),
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
