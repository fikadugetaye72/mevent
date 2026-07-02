import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/api_service.dart';
import '../home/home_controller.dart';

class CreateEventController extends GetxController {
  late final ApiService _api;

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final locationController = TextEditingController();

  final Rxn<DateTime> selectedDate = Rxn<DateTime>();
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _api = Get.find<ApiService>();
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    locationController.dispose();
    super.onClose();
  }

  Future<void> pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked == null) return;
    if (!context.mounted) return;

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(selectedDate.value ?? DateTime.now()),
    );
    if (pickedTime != null) {
      selectedDate.value = DateTime(
        picked.year,
        picked.month,
        picked.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    }
  }

  Future<void> submitEvent() async {
    final title = titleController.text.trim();
    final description = descriptionController.text.trim();
    final location = locationController.text.trim();
    final date = selectedDate.value;

    if (title.isEmpty || location.isEmpty || date == null) {
      Get.snackbar('ስህተት (Error)', 'እባክዎን ሁሉንም አስፈላጊ መረጃዎች ያስገቡ\n(Please fill all required fields)');
      return;
    }

    isLoading.value = true;

    try {
      // Create a Standard POST request with JSON
      final response = await _api.post('/events', {
        'title': title,
        'description': description,
        'date': date.toIso8601String(),
        'location': location,
      });

      if (response.statusCode == 201) {
        Get.snackbar('ስኬት (Success)', 'ዝግጅቱ በተሳካ ሁኔታ ተፈጥሯል (Event created successfully)');
        // Refresh home list if active
        if (Get.isRegistered<HomeController>()) {
          Get.find<HomeController>().fetchEvents();
        }
        Get.back();
      } else {
        Get.snackbar('ስህተት (Error)', 'ዝግጅቱን መፍጠር አልተቻለም (Could not create event)');
      }
    } catch (e) {
      Get.printError(info: 'Error creating event: $e');
      Get.snackbar('ስህተት (Error)', 'አንድ ችግር ተከስቷል (Something went wrong)');
    } finally {
      isLoading.value = false;
    }
  }
}
