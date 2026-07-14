import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Use 10.0.2.2 for Android Emulator, localhost for iOS/desktop/web
  static const String baseUrl = 'http://10.0.2.2:4000/api';

  String? _token;

  Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/admin/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        final user = data['user'];
        if (user != null && user['role'] != 'admin') {
          throw Exception('Access denied: Gate check-in is restricted to administrative personnel.');
        }

        _token = data['token'] as String?;
        if (_token != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('admin_token', _token!);
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Login error: $e');
      throw Exception(_cleanException(e));
    }
  }

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('admin_token');
  }

  Future<void> logout() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('admin_token');
  }

  bool get isAuthenticated => _token != null;

  Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      if (_token != null) 'Authorization': 'Bearer $_token',
    };
  }

  Future<List<dynamic>> _fetchEventsRaw() async {
    final response = await http.get(
      Uri.parse('$baseUrl/events'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      throw Exception('Failed to load events: ${response.body}');
    }
  }

  Future<List<dynamic>> fetchEvents() async {
    try {
      return await _fetchEventsRaw();
    } catch (e) {
      throw Exception(_cleanException(e));
    }
  }

  Future<Map<String, dynamic>> checkInTicket(String bookingId, String eventId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/bookings/$bookingId/check-in'),
        headers: _getHeaders(),
        body: jsonEncode({'eventId': eventId}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Ticket scanned & checked in successfully.',
          'booking': data['booking'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Ticket scanning verification failed.',
          'booking': data['booking'],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'connectionError': true,
        'message': _cleanException(e),
      };
    }
  }

  String _cleanException(dynamic e) {
    final errStr = e.toString().toLowerCase();
    if (errStr.contains('socketexception') || errStr.contains('connection refused') || errStr.contains('handshake_error')) {
      return 'Verification Server is offline. Please check your network connection and ensure the gate backend is running.';
    } else if (errStr.contains('timeout')) {
      return 'Request Timeout: The gate server took too long to respond. Please try again.';
    }
    return e.toString().replaceFirst('Exception: ', '');
  }
}
