import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';

class NotificationService extends GetxService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  String? fcmToken;

  Future<NotificationService> init() async {
    try {
      // Request notification permissions
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      Get.log('User granted notification permission: ${settings.authorizationStatus}');
      print('FCM: User granted notification permission: ${settings.authorizationStatus}');

      // Get FCM token
      print('FCM: Requesting FCM Token from FirebaseMessaging...');
      fcmToken = await _messaging.getToken();
      Get.log('FCM Token: $fcmToken');
      print('FCM: FCM Token successfully retrieved: $fcmToken');

      // Listen for token refreshes
      _messaging.onTokenRefresh.listen((newToken) {
        fcmToken = newToken;
        Get.log('FCM Token refreshed: $fcmToken');
        print('FCM: FCM Token refreshed: $fcmToken');
      });

      // Handle foreground notifications
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (message.notification != null) {
          showNotification(
            message.notification!.title ?? 'New Notification',
            message.notification!.body ?? '',
          );
        }
      });
    } catch (e, stackTrace) {
      Get.printError(info: 'Error initializing NotificationService: $e');
      print('FCM: Error initializing NotificationService: $e');
      print('FCM: StackTrace: $stackTrace');
    }
    return this;
  }

  void showNotification(String title, String body) {
    Get.log('Notification triggered: $title - $body');
    Get.snackbar(
      title,
      body,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 4),
    );
  }
}
