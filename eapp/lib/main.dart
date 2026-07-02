import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'ads/ad_service.dart';
import 'core/services/api_service.dart';
import 'core/services/auth_service.dart';
import 'core/services/storage_service.dart';
import 'notification/notification_service.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';
import 'ui/theme/app_theme.dart';
import 'utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Initialize persistent services
  final storage = await Get.putAsync(() => StorageService().init());
  Get.put(ApiService());
  await Get.putAsync(() => NotificationService().init());
  Get.put(AuthService());
  await Get.putAsync(() => AdService().init());

  final isDark = storage.readBool(Constants.themeKey) ?? false;

  runApp(MyApp(
    initialThemeMode: isDark ? ThemeMode.dark : ThemeMode.light,
  ));
}

class MyApp extends StatelessWidget {
  final ThemeMode initialThemeMode;

  const MyApp({
    super.key,
    required this.initialThemeMode,
  });

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'ዝግጅቶች አስተዳደር (Event Management)',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: initialThemeMode,
      initialRoute: AppRoutes.initial,
      getPages: AppPages.pages,
    );
  }
}
