import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'services/api_service.dart';
import 'theme/app_theme.dart';
import 'ui/screens/home_screen.dart';
import 'ui/screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Register API Service singleton
  final api = Get.put(ApiService());
  
  // Load persist token
  await api.loadToken();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final api = Get.find<ApiService>();

    return GetMaterialApp(
      title: 'Gate Entry Manager',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: api.isAuthenticated ? const HomeScreen() : const LoginScreen(),
    );
  }
}
