import 'dart:convert';
import 'package:get/get.dart';
import '../../../core/models/event.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/auth_service.dart';
import '../home/home_controller.dart';

class EventDetailController extends GetxController {
  late final ApiService _api;
  late final AuthService _auth;

  final Rxn<Event> event = Rxn<Event>();
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _api = Get.find<ApiService>();
    _auth = Get.find<AuthService>();
    final String? eventId = Get.arguments as String?;
    if (eventId != null) {
      fetchEventDetails(eventId);
    }
  }

  Future<void> fetchEventDetails(String id) async {
    isLoading.value = true;
    try {
      final response = await _api.get('/events/$id');
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        event.value = Event.fromJson(decoded as Map<String, dynamic>);
      }
    } catch (e) {
      Get.printError(info: 'Error fetching event detail: $e');
    } finally {
      isLoading.value = false;
    }
  }

  bool get isAdminOrOrganizer {
    final user = _auth.currentUser.value;
    return user != null;
  }

  Future<bool> deleteEvent() async {
    final currentEvent = event.value;
    if (currentEvent == null) return false;

    isLoading.value = true;
    try {
      final response = await _api.delete('/events/${currentEvent.id}');
      if (response.statusCode == 200 || response.statusCode == 204) {
        // Refresh home list if active
        if (Get.isRegistered<HomeController>()) {
          Get.find<HomeController>().fetchEvents();
        }
        return true;
      }
    } catch (e) {
      Get.printError(info: 'Error deleting event: $e');
    } finally {
      isLoading.value = false;
    }
    return false;
  }
}
