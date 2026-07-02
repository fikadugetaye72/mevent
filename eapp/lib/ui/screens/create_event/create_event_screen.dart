import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'create_event_controller.dart';

class CreateEventScreen extends StatelessWidget {
  const CreateEventScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CreateEventController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('አዲስ ዝግጅት መፍጠሪያ (Create Event)'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'የዝግጅቱን ዝርዝር መረጃ ያስገቡ',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Title input
              TextField(
                controller: controller.titleController,
                decoration: InputDecoration(
                  labelText: 'የዝግጅቱ ርዕስ * (Event Title *)',
                  prefixIcon: const Icon(Icons.title),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Location input
              TextField(
                controller: controller.locationController,
                decoration: InputDecoration(
                  labelText: 'ቦታ * (Location *)',
                  prefixIcon: const Icon(Icons.location_on_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Date input trigger
              Obx(() {
                final date = controller.selectedDate.value;
                final displayStr = date != null
                    ? DateFormat('EEEE, MMM dd, yyyy - hh:mm a').format(date)
                    : 'ቀን እና ሰዓት ይምረጡ * (Select Date & Time *)';

                return InkWell(
                  onTap: () => controller.pickDate(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined, color: Colors.blue),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            displayStr,
                            style: TextStyle(
                              fontSize: 15,
                              color: date != null ? Colors.black : Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 16),

              // Description input
              TextField(
                controller: controller.descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'ስለ ዝግጅቱ (Description)',
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 60.0),
                    child: Icon(Icons.description_outlined),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Submit Button
              Obx(() => ElevatedButton(
                    onPressed: controller.isLoading.value ? null : controller.submitEvent,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: controller.isLoading.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'ዝግጅት ፍጠር (Create Event)',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
