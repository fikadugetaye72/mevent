class Constants {
  // Use 10.0.2.2 for Android emulator to connect to local development server (port 4000)
  // Use localhost (127.0.0.1) for iOS simulator, web or physical devices
  static const String apiBaseUrl = 'http://10.0.2.2:4000/api';

  // Storage Keys
  static const String tokenKey = 'jwt_token';
  static const String userKey = 'logged_in_user';
  static const String themeKey = 'is_dark_mode';
}
