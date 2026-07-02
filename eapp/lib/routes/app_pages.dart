import 'package:get/get.dart';
import '../ui/screens/auth/login_screen.dart';
import '../ui/screens/auth/register_screen.dart';
import '../ui/screens/main_layout/main_layout_screen.dart';
import '../ui/screens/home/home_screen.dart';
import '../ui/screens/event_detail/event_detail_screen.dart';
import '../ui/screens/create_event/create_event_screen.dart';
import '../ui/screens/profile/profile_screen.dart';
import '../ui/screens/settings/settings_screen.dart';
import '../ui/screens/splash/splash_screen.dart';
import '../ui/screens/event_list/event_list_screen.dart';
import 'app_routes.dart';

abstract class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.initial,
      page: () => const SplashScreen(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterScreen(),
    ),
    GetPage(
      name: AppRoutes.mainLayout,
      page: () => const MainLayoutScreen(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeScreen(),
    ),
    GetPage(
      name: AppRoutes.eventDetail,
      page: () => const EventDetailScreen(),
    ),
    GetPage(
      name: AppRoutes.createEvent,
      page: () => const CreateEventScreen(),
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileScreen(),
    ),
    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsScreen(),
    ),
    GetPage(
      name: AppRoutes.eventList,
      page: () => const EventListScreen(),
    ),
  ];
}
