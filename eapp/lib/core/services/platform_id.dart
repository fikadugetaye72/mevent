import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:persistent_device_id/persistent_device_id.dart';

/// Provides device id information.
class PlatformDeviceId {
  /// Provides device and operating system information.
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  static const String _appDeviceIdKey = 'app_unique_device_id';

  /// Information derived from persistent device ID that survives app uninstalls
  /// Falls back to device characteristics-based ID if persistent ID fails
  static Future<String?> get getDeviceId async {
    try {
      // First try to get persistent device ID (survives app uninstalls)
      String? persistentId = await PersistentDeviceId.getDeviceId();
      if (persistentId != null && persistentId.isNotEmpty) {
        return persistentId;
      }
    } catch (e) {
      print('Persistent device ID failed: $e');
    }

    // Fallback: Try to get existing app-specific device ID from local storage
    final prefs = await SharedPreferences.getInstance();
    String? existingId = prefs.getString(_appDeviceIdKey);
    if (existingId != null && existingId.isNotEmpty) {
      return existingId;
    }

    // Fallback: Generate persistent device ID using device characteristics
    String persistentDeviceId = await _generatePersistentDeviceIdFromCharacteristics();

    // Store the persistent device ID for future use
    await prefs.setString(_appDeviceIdKey, persistentDeviceId);
    
    return persistentDeviceId;
  }

  /// Generate persistent device ID using device characteristics
  static Future<String> _generatePersistentDeviceIdFromCharacteristics() async {
    String? platformDeviceId;
    String? deviceModel;
    String? deviceBrand;
    String? systemVersion;
    
    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfoPlugin.androidInfo;
        platformDeviceId = androidInfo.id;
        deviceModel = androidInfo.model;
        deviceBrand = androidInfo.brand;
        systemVersion = androidInfo.version.release;
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfoPlugin.iosInfo;
        platformDeviceId = iosInfo.identifierForVendor;
        deviceModel = iosInfo.model;
        deviceBrand = iosInfo.name;
        systemVersion = iosInfo.systemVersion;
      }
    } on PlatformException {
      platformDeviceId = null;
    }

    // Create a hash from device characteristics that are relatively stable
    List<String> deviceCharacteristics = [];
    
    if (platformDeviceId != null && platformDeviceId.isNotEmpty) {
      deviceCharacteristics.add(platformDeviceId);
    }
    if (deviceModel != null && deviceModel.isNotEmpty) {
      deviceCharacteristics.add(deviceModel);
    }
    if (deviceBrand != null && deviceBrand.isNotEmpty) {
      deviceCharacteristics.add(deviceBrand);
    }
    if (systemVersion != null && systemVersion.isNotEmpty) {
      deviceCharacteristics.add(systemVersion);
    }

    // If we have device characteristics, create a hash-based ID
    if (deviceCharacteristics.isNotEmpty) {
      String combined = deviceCharacteristics.join('_');
      int hash = combined.hashCode.abs();
      return 'device_${hash}_${_generateRandomString(6)}';
    } else {
      // Fallback: generate completely unique ID
      return 'app_${DateTime.now().millisecondsSinceEpoch}_${_generateRandomString(12)}';
    }
  }

  /// Generate random string for uniqueness
  static String _generateRandomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(length, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
    );
  }
}
