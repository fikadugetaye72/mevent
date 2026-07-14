class Event {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String location;
  final String? imageUrl;
  final String code;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.location,
    this.imageUrl,
    required this.code,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      date: json['date'] != null ? DateTime.parse(json['date'] as String) : DateTime.now(),
      location: json['location'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      code: json['code'] as String? ?? '',
    );
  }
}
