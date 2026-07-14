class ScannedBooking {
  final String code;
  final String status;
  final bool checkedIn;
  final DateTime? checkedInAt;
  final String username;
  final String email;
  final String eventTitle;

  ScannedBooking({
    required this.code,
    required this.status,
    required this.checkedIn,
    this.checkedInAt,
    required this.username,
    required this.email,
    required this.eventTitle,
  });

  factory ScannedBooking.fromJson(Map<String, dynamic> json) {
    final userMap = json['user'] as Map<String, dynamic>? ?? {};
    return ScannedBooking(
      code: json['code'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      checkedIn: json['checkedIn'] as bool? ?? false,
      checkedInAt: json['checkedInAt'] != null ? DateTime.parse(json['checkedInAt'] as String) : null,
      username: userMap['username'] as String? ?? 'Guest User',
      email: userMap['email'] as String? ?? '',
      eventTitle: json['eventTitle'] as String? ?? '',
    );
  }
}
