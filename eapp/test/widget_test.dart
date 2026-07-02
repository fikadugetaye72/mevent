import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eapp/main.dart';
import 'package:get/get.dart';
import 'package:eapp/core/services/auth_service.dart';
import 'package:eapp/core/services/storage_service.dart';
import 'package:eapp/core/services/api_service.dart';
import 'package:eapp/ui/screens/splash/splash_screen.dart';

// Simple mock services to avoid database/network calls during tests
class MockStorageService extends StorageService {
  @override
  String? read(String key) => null;
  @override
  bool? readBool(String key) => false;
}

class MockApiService extends ApiService {}

class MockAuthService extends AuthService {
  @override
  void onInit() {
    // Avoid calling base class which seeks real storage/api
    isLoggedIn.value = false;
  }
  @override
  Future<void> autoLogin() async {
    // No-op
  }
}

void main() {
  setUp(() {
    // Clean up GetX between tests
    Get.reset();
  });

  testWidgets('App smoke test - splash screen mounts', (WidgetTester tester) async {
    // Register stub dependencies
    Get.put<StorageService>(MockStorageService());
    Get.put<ApiService>(MockApiService());
    Get.put<AuthService>(MockAuthService());

    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp(
      initialThemeMode: ThemeMode.light,
    ));

    // Verify SplashScreen is displayed
    expect(find.byType(SplashScreen), findsOneWidget);
    
    // Verify MEvent text is present
    expect(find.text('MEvent'), findsOneWidget);
  });
}
