import 'package:get/get.dart';
import '../../../core/services/auth_service.dart';
import '../../../routes/app_routes.dart';

class SplashController extends GetxController {
  late final AuthService _auth;

  @override
  void onInit() {
    super.onInit();
    _auth = Get.find<AuthService>();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // We want the splash screen animations to display nicely,
    // so we enforce a minimum duration for the splash screen (e.g., 2.5 seconds).
    final timerFuture = Future.delayed(const Duration(milliseconds: 2500));
    
    // Concurrently trigger auto-login checks (device-login / token checking)
    final loginFuture = _auth.autoLogin();

    // Wait for both the minimum display duration and the auto login logic to complete
    await Future.wait([timerFuture, loginFuture]);

    // Navigate to the appropriate screen
    if (_auth.isLoggedIn.value) {
      Get.offAllNamed(AppRoutes.mainLayout);
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
  }
}
