import 'package:flutter/material.dart';

class PoojaModel {
  final int id;
  final String name;
  final String description;
  final int pricePerPerson;
  final String colorHex;
  final String iconName;
  final String duration;
  final int displayOrder;
  final String info;
  final List<String> beforeInstructions;
  final List<String> afterInstructions;
  final List<String> thingsToBring;
  final bool enabled;

  const PoojaModel({
    required this.id,
    required this.name,
    required this.description,
    required this.pricePerPerson,
    required this.colorHex,
    required this.iconName,
    required this.duration,
    required this.displayOrder,
    required this.info,
    required this.beforeInstructions,
    required this.afterInstructions,
    required this.thingsToBring,
    required this.enabled,
  });

  Color get color {
    final hex = colorHex.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  IconData get icon => _iconMap[iconName] ?? Icons.auto_awesome;

  static const Map<String, IconData> _iconMap = {
    'auto_awesome': Icons.auto_awesome,
    'all_inclusive': Icons.all_inclusive,
    'local_fire_department': Icons.local_fire_department,
    'water_drop': Icons.water_drop,
    'self_improvement': Icons.self_improvement,
    'home_work': Icons.home_work,
    'temple_hindu': Icons.temple_hindu,
    'stars': Icons.stars,
  };

  factory PoojaModel.fromJson(Map<String, dynamic> json) {
    List<String> parseList(dynamic v) {
      if (v is List) return v.map((e) => e.toString()).toList();
      return [];
    }

    return PoojaModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      pricePerPerson: (json['pricePerPerson'] as num?)?.toInt() ?? 0,
      colorHex: json['colorHex'] as String? ?? '#1565C0',
      iconName: json['iconName'] as String? ?? 'auto_awesome',
      duration: json['duration'] as String? ?? '',
      displayOrder: (json['displayOrder'] as num?)?.toInt() ?? 0,
      info: json['info'] as String? ?? '',
      beforeInstructions: parseList(json['beforeInstructions']),
      afterInstructions: parseList(json['afterInstructions']),
      thingsToBring: parseList(json['thingsToBring']),
      enabled: json['enabled'] as bool? ?? true,
    );
  }
}
