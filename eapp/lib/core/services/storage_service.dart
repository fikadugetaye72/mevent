import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';

class StorageService extends GetxService {
  late final SharedPreferences _prefs;

  Future<StorageService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  Future<bool> write(String key, String value) async {
    return await _prefs.setString(key, value);
  }

  String? read(String key) {
    return _prefs.getString(key);
  }

  Future<bool> remove(String key) async {
    return await _prefs.remove(key);
  }

  Future<bool> writeBool(String key, bool value) async {
    return await _prefs.setBool(key, value);
  }

  bool? readBool(String key) {
    return _prefs.getBool(key);
  }

  Future<bool> clear() async {
    return await _prefs.clear();
  }
}
