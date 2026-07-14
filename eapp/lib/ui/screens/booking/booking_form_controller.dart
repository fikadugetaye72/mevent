import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/models/event.dart';
import '../../../core/services/api_service.dart';
import '../../../routes/app_routes.dart';
import 'my_bookings_controller.dart';

class BookingFormController extends GetxController {
  late final ApiService _api;
  late final Event event;

  final RxString ticketType = 'regular'.obs;
  final RxInt seats = 1.obs;
  final RxString screenshotPath = ''.obs;
  final RxBool isLoading = false.obs;

  final emailController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    _api = Get.find<ApiService>();
    
    // Retrieve event object passed as argument
    if (Get.arguments is Event) {
      event = Get.arguments as Event;
    } else {
      Get.back();
      Get.snackbar('Error', 'Invalid event details provided.');
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }

  double get ticketPrice {
    if (ticketType.value == 'vip') {
      return event.vipPrice ?? 0;
    }
    return event.price ?? 0;
  }

  double get totalCost => ticketPrice * seats.value;

  void selectTicketType(String type) {
    ticketType.value = type;
  }

  void incrementSeats() {
    seats.value++;
  }

  void decrementSeats() {
    if (seats.value > 1) {
      seats.value--;
    }
  }

  Future<void> pickScreenshot() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (pickedFile != null) {
        screenshotPath.value = pickedFile.path;
      }
    } catch (e) {
      Get.printError(info: 'Error picking screenshot: $e');
      Get.snackbar('Error', 'Failed to pick screenshot image.');
    }
  }

  void removeScreenshot() {
    screenshotPath.value = '';
  }

  Future<void> submitBooking() async {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      Get.snackbar('Error', 'Please enter your email address.');
      return;
    }
    if (!GetUtils.isEmail(email)) {
      Get.snackbar('Error', 'Please enter a valid email address.');
      return;
    }

    if (screenshotPath.value.isEmpty) {
      Get.snackbar('Error', 'Please upload a transaction screenshot to confirm payment.');
      return;
    }

    isLoading.value = true;
    try {
      // 1. Upload receipt to server
      final uploadResponse = await _api.uploadFile('/upload', screenshotPath.value);
      if (uploadResponse.statusCode != 200 && uploadResponse.statusCode != 201) {
        final errorMsg = jsonDecode(uploadResponse.body)['message'] ?? 'Upload failed.';
        Get.snackbar('Error', 'Transaction receipt upload failed: $errorMsg');
        isLoading.value = false;
        return;
      }

      final uploadResult = jsonDecode(uploadResponse.body);
      final String screenshotUrl = uploadResult['url'];

      // 2. Post booking data
      final bookingResponse = await _api.post('/bookings', {
        'eventId': event.id,
        'ticketType': ticketType.value,
        'seats': seats.value,
        'screenshotUrl': screenshotUrl,
        'email': email,
      });

      if (bookingResponse.statusCode == 201) {
        Get.snackbar('Success', 'Booking submitted successfully!');
        
        // Refresh bookings controller if already active
        if (Get.isRegistered<MyBookingsController>()) {
          Get.find<MyBookingsController>().fetchBookings();
        }
        
        // Redirect to user's bookings screen
        Get.offNamed(AppRoutes.myBookings);
      } else {
        final errorMsg = jsonDecode(bookingResponse.body)['message'] ?? 'Booking failed.';
        Get.snackbar('Error', 'Booking submission failed: $errorMsg');
      }
    } catch (e) {
      Get.printError(info: 'Booking submission error: $e');
      Get.snackbar('Error', 'Something went wrong during checkout.');
    } finally {
      isLoading.value = false;
    }
  }
}
