import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../routes/app_routes.dart';
import '../../../utils/constants.dart';

class SettingsController extends GetxController {
  late final AuthService _auth;
  late final StorageService _storage;

  final RxBool isDarkMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    _auth = Get.find<AuthService>();
    _storage = Get.find<StorageService>();
    isDarkMode.value = _storage.readBool(Constants.themeKey) ?? false;
  }

  void toggleTheme(bool value) {
    isDarkMode.value = value;
    _storage.writeBool(Constants.themeKey, value);
    Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
  }

  void logout() {
    _auth.logout();
    Get.offAllNamed(AppRoutes.login);
  }
}
