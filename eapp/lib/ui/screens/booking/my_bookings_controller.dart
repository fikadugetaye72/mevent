import 'dart:convert';
import 'package:get/get.dart';
import '../../../core/models/event.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/auth_service.dart';

class BookingUser {
  final String id;
  final String username;
  final String email;

  BookingUser({required this.id, required this.username, required this.email});

  factory BookingUser.fromJson(Map<String, dynamic> json) {
    return BookingUser(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
    );
  }
}

class Booking {
  final String id;
  final BookingUser user;
  final Event event;
  final String ticketType;
  final int seats;
  final double totalPaid;
  final String screenshotUrl;
  final String status;
  final DateTime createdAt;
  final String code;
  final String cancellationReason;

  Booking({
    required this.id,
    required this.user,
    required this.event,
    required this.ticketType,
    required this.seats,
    required this.totalPaid,
    required this.screenshotUrl,
    required this.status,
    required this.createdAt,
    required this.code,
    required this.cancellationReason,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    // Parse user
    BookingUser parsedUser = BookingUser(id: '', username: '', email: '');
    if (json['user'] != null) {
      if (json['user'] is Map<String, dynamic>) {
        parsedUser = BookingUser.fromJson(json['user'] as Map<String, dynamic>);
      } else if (json['user'] is String) {
        parsedUser = BookingUser(id: json['user'] as String, username: '', email: '');
      }
    }

    // Parse event
    Event parsedEvent = Event(
      id: '',
      title: 'Event details unavailable',
      description: '',
      date: DateTime.now(),
      location: '',
    );
    if (json['event'] != null && json['event'] is Map<String, dynamic>) {
      parsedEvent = Event.fromJson(json['event'] as Map<String, dynamic>);
    }

    return Booking(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      user: parsedUser,
      event: parsedEvent,
      ticketType: json['ticketType'] as String? ?? 'regular',
      seats: json['seats'] as int? ?? 1,
      totalPaid: json['totalPaid'] != null ? (json['totalPaid'] as num).toDouble() : 0.0,
      screenshotUrl: json['screenshotUrl'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : DateTime.now(),
      code: json['code'] as String? ?? '',
      cancellationReason: json['cancellationReason'] as String? ?? '',
    );
  }
}

class MyBookingsController extends GetxController {
  late final ApiService _api;
  late final AuthService _auth;

  final RxList<Booking> bookings = <Booking>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _api = Get.find<ApiService>();
    _auth = Get.find<AuthService>();
    fetchBookings();
  }

  Future<void> fetchBookings() async {
    isLoading.value = true;
    try {
      final response = await _api.get('/bookings');
      if (response.statusCode == 200) {
        final List<dynamic> decodedList = jsonDecode(response.body);
        bookings.value = decodedList
            .map((item) => Booking.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        Get.snackbar('Error', 'Failed to retrieve bookings list.');
      }
    } catch (e) {
      Get.printError(info: 'Error fetching bookings: $e');
      Get.snackbar('Error', 'Something went wrong fetching bookings.');
    } finally {
      isLoading.value = false;
    }
  }
}
