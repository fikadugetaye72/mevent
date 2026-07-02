import 'dart:convert';
import 'package:get/get.dart';
import '../models/user.dart';
import 'api_service.dart';
import 'storage_service.dart';
import 'platform_id.dart';
import '../../notification/notification_service.dart';
import '../../utils/constants.dart';

class AuthService extends GetxService {
  late final ApiService _api;
  late final StorageService _storage;

  final Rxn<User> currentUser = Rxn<User>();
  final RxBool isLoggedIn = false.obs;

  @override
  void onInit() {
    super.onInit();
    _api = Get.find<ApiService>();
    _storage = Get.find<StorageService>();
    
    // TEMPORARY: Clear cached credentials for testing fresh registration
    // _storage.remove(Constants.tokenKey);
    // _storage.remove(Constants.userKey);
    // print('DEBUG: Cleared cached credentials (token and user) from storage for testing.');
    
    loadUserSession();
  }

  /// Initialize and load saved sessions
  void loadUserSession() {
    final String? token = _storage.read(Constants.tokenKey);
    final String? userData = _storage.read(Constants.userKey);

    if (token != null && userData != null) {
      try {
        final Map<String, dynamic> userJson = jsonDecode(userData);
        currentUser.value = User.fromJson(userJson);
        isLoggedIn.value = true;
      } catch (e) {
        logout();
      }
    }
  }

  /// Automatically login using device ID and FCM token if no session exists
  Future<void> autoLogin() async {
    // 1. Try to load local session first (instant load)
    loadUserSession();
    if (isLoggedIn.value) {
      Get.log('User session loaded from local storage');
      return;
    }

    // 2. No local session, perform device registration/login
    Get.log('No local session. Starting device auto-login...');
    try {
      final String? deviceId = await PlatformDeviceId.getDeviceId;
      if (deviceId == null || deviceId.isEmpty) {
        Get.printError(info: 'Unable to retrieve Device ID');
        return;
      }

      String? fcmToken;
      try {
        final notificationService = Get.find<NotificationService>();
        fcmToken = notificationService.fcmToken;
        print('FCM in Auth: Successfully read FCM token from NotificationService: $fcmToken');
      } catch (e) {
        Get.printError(info: 'NotificationService not initialized yet: $e');
        print('FCM in Auth: Error finding NotificationService or reading FCM token: $e');
      }

      final response = await _api.post('/auth/device-login', {
        'deviceId': deviceId,
        'fcmToken': fcmToken,
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String token = data['token'] as String;
        final user = User.fromJson(data['user'] as Map<String, dynamic>);

        await _storage.write(Constants.tokenKey, deviceId);
        print('FCM in Auth: Storing deviceId as token instead of JWT: $deviceId');
        await _storage.write(Constants.userKey, jsonEncode(user.toJson()));

        currentUser.value = user;
        isLoggedIn.value = true;
        Get.log('Device auto-login completed successfully. Logged in as: ${user.username}');
      } else {
        Get.printError(info: 'Device auto-login failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      Get.printError(info: 'Device auto-login exception: $e');
    }
  }

  /// Login a user
  Future<bool> login(String email, String password) async {
    try {
      final response = await _api.post('/auth/login', {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String token = data['token'] as String;
        final user = User.fromJson(data['user'] as Map<String, dynamic>);

        await _storage.write(Constants.tokenKey, token);
        await _storage.write(Constants.userKey, jsonEncode(user.toJson()));

        currentUser.value = user;
        isLoggedIn.value = true;
        return true;
      }
    } catch (e) {
      Get.printError(info: 'Login error: $e');
    }
    return false;
  }

  /// Register a user
  Future<bool> register(String username, String email, String password) async {
    try {
      final response = await _api.post('/auth/register', {
        'username': username,
        'email': email,
        'password': password,
      });

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String token = data['token'] as String;
        final user = User.fromJson(data['user'] as Map<String, dynamic>);

        await _storage.write(Constants.tokenKey, token);
        await _storage.write(Constants.userKey, jsonEncode(user.toJson()));

        currentUser.value = user;
        isLoggedIn.value = true;
        return true;
      }
    } catch (e) {
      Get.printError(info: 'Registration error: $e');
    }
    return false;
  }

  /// Logout a user
  void logout() {
    _storage.remove(Constants.tokenKey);
    _storage.remove(Constants.userKey);
    currentUser.value = null;
    isLoggedIn.value = false;
  }
}
