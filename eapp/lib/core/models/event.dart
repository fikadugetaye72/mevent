class Category {
  final String id;
  final String name;

  Category({required this.id, required this.name});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class Speaker {
  final String name;
  final String imageUrl;

  Speaker({required this.name, required this.imageUrl});

  factory Speaker.fromJson(Map<String, dynamic> json) {
    return Speaker(
      name: json['name'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'imageUrl': imageUrl,
    };
  }
}

class Organizer {
  final String name;
  final String imageUrl;

  Organizer({required this.name, required this.imageUrl});

  factory Organizer.fromJson(Map<String, dynamic> json) {
    return Organizer(
      name: json['name'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'imageUrl': imageUrl,
    };
  }
}

class Event {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String location;
  final String? imageUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  
  // Extended fields
  final List<String> tags;
  final List<Speaker> speakers;
  final int? totalSeats;
  final int? vipSeats;
  final List<Organizer> organizers;
  final double? price;
  final double? vipPrice;
  final String status;
  final String? phone;
  final Category? category;
  final bool featured;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.location,
    this.imageUrl,
    this.createdAt,
    this.updatedAt,
    this.tags = const [],
    this.speakers = const [],
    this.totalSeats,
    this.vipSeats,
    this.organizers = const [],
    this.price,
    this.vipPrice,
    this.status = 'active',
    this.phone,
    this.category,
    this.featured = false,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    // Parse tags
    List<String> tagsList = [];
    if (json['tags'] != null) {
      tagsList = List<String>.from(json['tags']);
    }

    // Parse speakers
    List<Speaker> speakersList = [];
    if (json['speakers'] != null) {
      speakersList = (json['speakers'] as List)
          .map((s) => Speaker.fromJson(s as Map<String, dynamic>))
          .toList();
    }

    // Parse organizers
    List<Organizer> organizersList = [];
    if (json['organizers'] != null) {
      organizersList = (json['organizers'] as List)
          .map((o) => Organizer.fromJson(o as Map<String, dynamic>))
          .toList();
    }

    // Parse category
    Category? parsedCategory;
    if (json['category'] != null) {
      if (json['category'] is Map<String, dynamic>) {
        parsedCategory = Category.fromJson(json['category'] as Map<String, dynamic>);
      } else if (json['category'] is String) {
        parsedCategory = Category(id: json['category'] as String, name: '');
      }
    }

    return Event(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      date: json['date'] != null ? DateTime.parse(json['date'] as String) : DateTime.now(),
      location: json['location'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'] as String) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt'] as String) : null,
      tags: tagsList,
      speakers: speakersList,
      totalSeats: json['totalSeats'] as int?,
      vipSeats: json['vipSeats'] as int?,
      organizers: organizersList,
      price: json['price'] != null ? (json['price'] as num).toDouble() : null,
      vipPrice: json['vipPrice'] != null ? (json['vipPrice'] as num).toDouble() : null,
      status: json['status'] as String? ?? 'active',
      phone: json['phone'] as String?,
      category: parsedCategory,
      featured: json['featured'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'location': location,
      'imageUrl': imageUrl,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'tags': tags,
      'speakers': speakers.map((s) => s.toJson()).toList(),
      'totalSeats': totalSeats,
      'vipSeats': vipSeats,
      'organizers': organizers.map((o) => o.toJson()).toList(),
      'price': price,
      'vipPrice': vipPrice,
      'status': status,
      'phone': phone,
      'category': category?.toJson(),
      'featured': featured,
    };
  }
}
