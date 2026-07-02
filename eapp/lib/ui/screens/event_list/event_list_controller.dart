import 'dart:convert';
import 'package:get/get.dart';
import '../../../core/models/event.dart';
import '../../../core/services/api_service.dart';

class EventListController extends GetxController {
  late final ApiService _api;

  final RxList<Event> events = <Event>[].obs;
  final RxList<Category> categories = <Category>[].obs;
  final RxBool isLoading = false.obs;
  final RxString selectedCategory = 'All'.obs;

  @override
  void onInit() {
    super.onInit();
    _api = Get.find<ApiService>();
    
    // Read category parameter if passed from home screen
    if (Get.arguments is String) {
      selectedCategory.value = Get.arguments as String;
    }
    
    fetchData();
  }

  Future<void> fetchData() async {
    isLoading.value = true;
    try {
      await Future.wait([
        fetchEvents(),
        fetchCategories(),
      ]);
    } catch (e) {
      Get.printError(info: 'Error fetching list data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchEvents() async {
    try {
      final response = await _api.get('/events');
      if (response.statusCode == 200) {
        final List<dynamic> decodedList = jsonDecode(response.body);
        events.value = decodedList
            .map((item) => Event.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      Get.printError(info: 'Error fetching events: $e');
    }
  }

  Future<void> fetchCategories() async {
    try {
      final response = await _api.get('/categories');
      if (response.statusCode == 200) {
        final List<dynamic> decodedList = jsonDecode(response.body);
        categories.value = decodedList
            .map((item) => Category.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      Get.printError(info: 'Error fetching categories: $e');
    }
  }

  List<String> get categoryNames {
    final List<String> names = ['All'];
    for (var cat in categories) {
      if (cat.name.isNotEmpty && !names.contains(cat.name)) {
        names.add(cat.name);
      }
    }
    // Fallback parsing from events
    if (names.length == 1) {
      for (var e in events) {
        if (e.category != null && e.category!.name.isNotEmpty) {
          if (!names.contains(e.category!.name)) {
            names.add(e.category!.name);
          }
        }
      }
    }
    return names;
  }

  List<Event> get filteredEvents {
    if (selectedCategory.value == 'All') {
      return events;
    }
    return events.where((e) => e.category?.name == selectedCategory.value).toList();
  }
}
