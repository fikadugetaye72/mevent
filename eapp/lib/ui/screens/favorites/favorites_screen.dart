import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'favorites_controller.dart';
import '../../theme/app_theme.dart';
import '../../../core/models/event.dart';
import '../../../utils/constants.dart';
import '../../../routes/app_routes.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  String _resolveImageUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }
    final baseUrl = Constants.apiBaseUrl.replaceAll('/api', '');
    if (url.startsWith('/')) {
      return '$baseUrl$url';
    }
    return '$baseUrl/$url';
  }

  Widget _buildEventCard(BuildContext context, Event event, FavoritesController controller) {
    final dateStr = DateFormat('MMM dd, yyyy').format(event.date);
    final timeStr = DateFormat('hh:mm a').format(event.date);
    final imageUrl = _resolveImageUrl(event.imageUrl);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade100),
      ),
      clipBehavior: Clip.antiAlias,
      elevation: 0.5,
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
              // Event Thumbnail Image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 100,
                  height: 90,
                  color: Colors.blue.shade50,
                  child: imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(
                            Icons.broken_image_outlined,
                            size: 32,
                            color: AppColors.secondaryBlue,
                          ),
                        )
                      : const Icon(
                          Icons.image_outlined,
                          size: 32,
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            event.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.primaryDark,
                              fontSize: 15.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        // Unfavorite button
                        GestureDetector(
                          onTap: () => controller.toggleFavorite(event),
                          child: const Icon(
                            Icons.favorite,
                            color: AppColors.accentCoral,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

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
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        Icon(Icons.calendar_month_rounded, size: 13, color: Colors.grey.shade500),
                        const SizedBox(width: 3),
                        Text(
                          '$dateStr - $timeStr',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded, size: 13, color: AppColors.secondaryBlue),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event.location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 11.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          event.price == null || event.price == 0
                              ? 'Free'
                              : '${event.price!.toStringAsFixed(0)} ETB',
                          style: const TextStyle(
                            color: AppColors.secondaryBlue,
                            fontWeight: FontWeight.w800,
                            fontSize: 12.5,
                          ),
                        ),
                        if (event.vipPrice != null && event.vipPrice! > 0)
                          Text(
                            'VIP: ${event.vipPrice!.toStringAsFixed(0)} ETB',
                            style: const TextStyle(
                              color: AppColors.accentCoral,
                              fontWeight: FontWeight.w800,
                              fontSize: 12.5,
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
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(FavoritesController());

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: const Text(
          'Saved Events',
          style: TextStyle(
            color: AppColors.primaryDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Obx(() {
        final list = controller.favoriteEvents;
        if (list.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.accentCoral.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.favorite_outline_rounded,
                      size: 64,
                      color: AppColors.accentCoral,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'No Saved Events Yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your liked or bookmarked events will appear here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: list.length,
          itemBuilder: (context, index) {
            return _buildEventCard(context, list[index], controller);
          },
        );
      }),
    );
  }
}
