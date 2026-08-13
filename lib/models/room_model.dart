class RoomModel {
  final int id;
  final String name;
  final String type;
  final int pricePerNight;
  final String capacity;
  final List<String> amenities;
  final String description;
  final String imageUrl;
  final bool available;
  final int displayOrder;
  final int count;
  int availableCount;

  RoomModel({
    required this.id,
    required this.name,
    required this.type,
    required this.pricePerNight,
    required this.capacity,
    required this.amenities,
    required this.description,
    required this.imageUrl,
    required this.available,
    required this.displayOrder,
    required this.count,
  }) : availableCount = count;

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    List<String> parseList(dynamic v) {
      if (v is List) return v.map((e) => e.toString()).toList();
      return [];
    }

    return RoomModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      type: json['type'] as String? ?? 'Non-AC',
      pricePerNight: (json['pricePerNight'] as num?)?.toInt() ?? 0,
      capacity: json['capacity'] as String? ?? '2 Persons',
      amenities: parseList(json['amenities']),
      description: json['description'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      available: json['available'] as bool? ?? true,
      displayOrder: (json['displayOrder'] as num?)?.toInt() ?? 0,
      count: (json['count'] as num?)?.toInt() ?? 1,
    );
  }
}
