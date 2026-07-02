import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'event_detail_controller.dart';

class EventDetailScreen extends StatelessWidget {
  const EventDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EventDetailController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('የዝግጅት ዝርዝር (Event Details)'),
        actions: [
          Obx(() {
            if (controller.isAdminOrOrganizer && controller.event.value != null) {
              return IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => _confirmDelete(context, controller),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final event = controller.event.value;
        if (event == null) {
          return const Center(
            child: Text('ዝግጅቱ አልተገኘም (Event not found)'),
          );
        }

        final dateStr = DateFormat('EEEE, MMMM dd, yyyy - hh:mm a').format(event.date);

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Event Image Header
              Container(
                height: 250,
                color: Colors.blue.shade100,
                child: event.imageUrl != null && event.imageUrl!.isNotEmpty
                    ? Image.network(event.imageUrl!, fit: BoxFit.cover)
                    : const Icon(Icons.image, size: 72, color: Colors.blue),
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
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Date Row
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, color: Colors.blue),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'ቀን እና ሰዓት (Date & Time)',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                dateStr,
                                style: const TextStyle(fontSize: 15),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Location Row
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.red),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'ቦታ (Location)',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                event.location,
                                style: const TextStyle(fontSize: 15),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 32),

                    // Description Label
                    const Text(
                      'ስለ ዝግጅቱ (Description)',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Description Content
                    Text(
                      event.description.isNotEmpty
                          ? event.description
                          : 'ስለዚህ ዝግጅት የተሰጠ መግለጫ የለም (No description provided for this event).',
                      style: const TextStyle(fontSize: 16, height: 1.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  void _confirmDelete(BuildContext context, EventDetailController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('ዝግጅት ይሰረዝ? (Delete Event?)'),
        content: const Text('ይህንን ዝግጅት በቋሚነት መሰረዝ ይፈልጋሉ?\n(Are you sure you want to delete this event?)'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('አይ (Cancel)'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              final success = await controller.deleteEvent();
              if (success) {
                Get.back();
                Get.snackbar('ተሰርዟል', 'ዝግጅቱ በተሳካ ሁኔታ ተሰርዟል');
              } else {
                Get.snackbar('ስህተት', 'ዝግጅቱን መሰረዝ አልተቻለም');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('አዎ (Delete)', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
