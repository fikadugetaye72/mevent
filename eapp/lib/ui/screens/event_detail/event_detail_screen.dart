import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'event_detail_controller.dart';
import '../favorites/favorites_controller.dart';
import '../../theme/app_theme.dart';
import '../../../core/models/event.dart';
import '../../../utils/constants.dart';
import '../../../routes/app_routes.dart';

class EventDetailScreen extends StatelessWidget {
  const EventDetailScreen({super.key});

  // Resolve absolute/relative image URLs
  String _resolveImageUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }
    // Clean base API URL to get the root host (e.g. from "http://10.0.2.2:4000/api" to "http://10.0.2.2:4000")
    final baseUrl = Constants.apiBaseUrl.replaceAll('/api', '');
    if (url.startsWith('/')) {
      return '$baseUrl$url';
    }
    return '$baseUrl/$url';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green.shade600;
      case 'completed':
        return Colors.blue.shade600;
      case 'cancelled':
        return AppColors.accentCoral;
      case 'draft':
      default:
        return Colors.orange.shade700;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return 'Active';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      case 'draft':
      default:
        return 'Draft';
    }
  }

  Widget _buildHeaderImage(Event event) {
    final imageUrl = _resolveImageUrl(event.imageUrl);
    if (imageUrl.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primaryDark,
              AppColors.secondaryBlue.withOpacity(0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const Icon(Icons.event_note, size: 80, color: Colors.white70),
      );
    }
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        color: AppColors.primaryDark.withOpacity(0.05),
        child: const Icon(Icons.broken_image_outlined, size: 64, color: AppColors.secondaryBlue),
      ),
    );
  }

  Widget _buildStatBlock(IconData icon, String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.15), width: 1),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.primaryDark,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
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

  Widget _buildInfoRow(IconData icon, String title, String value, Color iconColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.primaryDark,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSpeakersSection(List<Speaker> speakers) {
    if (speakers.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 32, thickness: 0.8),
        const Text(
          'Speakers',
          style: TextStyle(
            color: AppColors.primaryDark,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: speakers.length,
            itemBuilder: (context, index) {
              final speaker = speakers[index];
              final speakerImg = _resolveImageUrl(speaker.imageUrl);
              return Container(
                width: 80,
                margin: const EdgeInsets.only(right: 16),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.blue.shade50,
                      backgroundImage: speakerImg.isNotEmpty ? NetworkImage(speakerImg) : null,
                      child: speakerImg.isEmpty
                          ? const Icon(Icons.person, color: AppColors.secondaryBlue, size: 28)
                          : null,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      speaker.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.primaryDark,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOrganizersSection(List<Organizer> organizers) {
    if (organizers.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 32, thickness: 0.8),
        const Text(
          'Organizers',
          style: TextStyle(
            color: AppColors.primaryDark,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: organizers.length,
            itemBuilder: (context, index) {
              final organizer = organizers[index];
              final orgImg = _resolveImageUrl(organizer.imageUrl);
              return Container(
                width: 80,
                margin: const EdgeInsets.only(right: 16),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.blue.shade50,
                      backgroundImage: orgImg.isNotEmpty ? NetworkImage(orgImg) : null,
                      child: orgImg.isEmpty
                          ? const Icon(Icons.business, color: AppColors.secondaryBlue, size: 28)
                          : null,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      organizer.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.primaryDark,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTagsSection(List<String> tags) {
    if (tags.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 32, thickness: 0.8),
        const Text(
          'Tags',
          style: TextStyle(
            color: AppColors.primaryDark,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: tags.map((tag) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryDark.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primaryDark.withOpacity(0.1)),
              ),
              child: Text(
                '#$tag',
                style: const TextStyle(
                  color: AppColors.primaryDark,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EventDetailController());

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.secondaryBlue),
          );
        }

        final event = controller.event.value;
        if (event == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Event Details'),
            ),
            body: const Center(
              child: Text('Event not found'),
            ),
          );
        }

        final dateStr = DateFormat('EEEE, MMMM dd, yyyy - hh:mm a').format(event.date);

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Event Image Header Stack
              Stack(
                children: [
                  Container(
                    height: 280,
                    width: double.infinity,
                    color: Colors.blue.shade50,
                    child: _buildHeaderImage(event),
                  ),
                  // Gradient overlay on bottom of image for readability of badges
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.transparent, Colors.black.withOpacity(0.4)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [0.7, 1.0],
                        ),
                      ),
                    ),
                  ),
                  // Floating Back Button
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 8,
                    left: 16,
                    child: CircleAvatar(
                      backgroundColor: Colors.black.withOpacity(0.35),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Get.back(),
                      ),
                    ),
                  ),
                  // Floating Favorite/Save Action
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 8,
                    right: 16,
                    child: Obx(() {
                      final currentEvent = controller.event.value;
                      if (currentEvent == null) return const SizedBox.shrink();

                      final favoritesController = Get.put(FavoritesController());
                      final isSaved = favoritesController.isFavorite(currentEvent.id);

                      return CircleAvatar(
                        backgroundColor: Colors.black.withOpacity(0.35),
                        child: IconButton(
                          icon: Icon(
                            isSaved ? Icons.favorite : Icons.favorite_border,
                            color: isSaved ? AppColors.accentCoral : Colors.white,
                          ),
                          onPressed: () => favoritesController.toggleFavorite(currentEvent),
                        ),
                      );
                    }),
                  ),
                  // Floating Badges at Bottom-Left (Featured & Category)
                  Positioned(
                    bottom: 12,
                    left: 16,
                    child: Row(
                      children: [
                        if (event.featured)
                          Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade700,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.star, color: Colors.white, size: 14),
                                SizedBox(width: 4),
                                Text(
                                  'Featured',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (event.category != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.secondaryBlue,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              event.category!.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Floating Status Pill at Bottom-Right
                  Positioned(
                    bottom: 12,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getStatusColor(event.status),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        _getStatusLabel(event.status),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      event.title,
                      style: const TextStyle(
                        color: AppColors.primaryDark,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Quick Stats/Details Card
                    Row(
                      children: [
                        _buildStatBlock(
                          Icons.local_activity_rounded,
                          'REGULAR PRICE',
                          event.price == null || event.price == 0 ? 'Free' : '${event.price!.toStringAsFixed(0)} ETB',
                          AppColors.secondaryBlue,
                        ),
                        const SizedBox(width: 12),
                        _buildStatBlock(
                          Icons.stars_rounded,
                          'VIP PRICE',
                          event.vipPrice == null || event.vipPrice == 0 ? 'N/A' : '${event.vipPrice!.toStringAsFixed(0)} ETB',
                          AppColors.accentCoral,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildStatBlock(
                          Icons.airline_seat_recline_normal_rounded,
                          'TOTAL SEATS',
                          event.totalSeats == null ? 'Unlimited' : '${event.totalSeats}',
                          Colors.purple.shade600,
                        ),
                        const SizedBox(width: 12),
                        _buildStatBlock(
                          Icons.workspace_premium_rounded,
                          'VIP SEATS',
                          event.vipSeats == null ? 'N/A' : '${event.vipSeats}',
                          Colors.deepOrange.shade600,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Event Meta Cards (Date, Location, Contact)
                    Card(
                      elevation: 0.5,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: Colors.grey.shade100),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            // Date & Time Row
                            _buildInfoRow(
                              Icons.calendar_today_rounded,
                              'Date & Time',
                              dateStr,
                              Colors.indigo,
                            ),
                            const Divider(height: 24, thickness: 0.8),
                            // Location Row
                            _buildInfoRow(
                              Icons.location_on_rounded,
                              'Location',
                              event.location,
                              Colors.red.shade600,
                            ),
                            if (event.phone != null && event.phone!.trim().isNotEmpty) ...[
                              const Divider(height: 24, thickness: 0.8),
                              // Phone Row
                              _buildInfoRow(
                                Icons.phone_in_talk_rounded,
                                'Phone Number',
                                event.phone!,
                                Colors.green.shade600,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Description Label
                    const Text(
                      'Description',
                      style: TextStyle(
                        color: AppColors.primaryDark,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Description Content
                    Text(
                      event.description.isNotEmpty
                          ? event.description
                          : 'No description provided for this event.',
                      style: TextStyle(
                        color: Colors.grey.shade800,
                        fontSize: 15,
                        height: 1.6,
                      ),
                    ),

                    // Inline Book Tickets Button (visible only if event status is active)
                    if (event.status.toLowerCase() == 'active') ...[
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => Get.toNamed(AppRoutes.bookingForm, arguments: event),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondaryBlue,
                          minimumSize: const Size(double.infinity, 52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 1,
                        ),
                        child: const Text(
                          'Book Tickets Now',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],

                    // Speakers Section
                    _buildSpeakersSection(event.speakers),

                    // Organizers Section
                    _buildOrganizersSection(event.organizers),

                    // Tags Section
                    _buildTagsSection(event.tags),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
      // Sticky bottom bar
      bottomNavigationBar: Obx(() {
        final event = controller.event.value;
        if (event == null || event.status.toLowerCase() != 'active') {
          return const SizedBox.shrink();
        }

        final priceRangeStr = event.price == null || event.price == 0
            ? 'Free'
            : '${event.price!.toStringAsFixed(0)} ETB';

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'REGULAR PRICE',
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      priceRangeStr,
                      style: const TextStyle(
                        color: AppColors.primaryDark,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () => Get.toNamed(AppRoutes.bookingForm, arguments: event),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDark,
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Book Now',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
