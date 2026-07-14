import 'dart:convert';
import 'package:get/get.dart';
import '../../../core/models/event.dart';
import '../../../core/services/storage_service.dart';

class FavoritesController extends GetxController {
  late final StorageService _storage;
  final RxList<Event> favoriteEvents = <Event>[].obs;
  static const String _storageKey = 'favorite_events';

  @override
  void onInit() {
    super.onInit();
    _storage = Get.find<StorageService>();
    loadFavorites();
  }

  void loadFavorites() {
    try {
      final String? rawData = _storage.read(_storageKey);
      if (rawData != null && rawData.isNotEmpty) {
        final List<dynamic> decodedList = jsonDecode(rawData);
        favoriteEvents.value = decodedList
            .map((item) => Event.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      Get.printError(info: 'Error loading favorites: $e');
    }
  }

  bool isFavorite(String eventId) {
    return favoriteEvents.any((e) => e.id == eventId);
  }

  Future<void> toggleFavorite(Event event) async {
    final index = favoriteEvents.indexWhere((e) => e.id == event.id);
    if (index >= 0) {
      favoriteEvents.removeAt(index);
    } else {
      favoriteEvents.add(event);
    }
    await _saveToStorage();
  }

  Future<void> _saveToStorage() async {
    try {
      final List<Map<String, dynamic>> rawList =
          favoriteEvents.map((e) => e.toJson()).toList();
      final String encoded = jsonEncode(rawList);
      await _storage.write(_storageKey, encoded);
    } catch (e) {
      Get.printError(info: 'Error saving favorites: $e');
    }
  }
}
