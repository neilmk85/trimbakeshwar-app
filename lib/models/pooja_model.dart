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
  final int stayRatePerNight;
  final bool privatePooja;
  final int privatePoojaRate;
  final List<DateTime> muhurtaDates;
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
    this.stayRatePerNight = 0,
    this.privatePooja = false,
    this.privatePoojaRate = 0,
    this.muhurtaDates = const [],
    required this.enabled,
  });

  /// Parses the numeric day count from [duration] (e.g. "2 Days" → 2).
  /// Returns 1 if the string contains no recognisable number.
  int get durationDays {
    final match = RegExp(r'\d+').firstMatch(duration);
    if (match == null) return 1;
    return int.tryParse(match.group(0)!) ?? 1;
  }

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

  /// Builds a local-only model from an [AppData.poojas] map entry.
  factory PoojaModel.fromAppData(Map<String, dynamic> data) {
    final color = data['color'] as Color? ?? const Color(0xFF1565C0);
    final hex = '#${(color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';
    final icon = data['icon'] as IconData?;
    final iconName = icon == null
        ? 'auto_awesome'
        : (_iconMap.entries
                .where((e) => e.value.codePoint == icon.codePoint)
                .map((e) => e.key)
                .firstOrNull ??
            'auto_awesome');
    return PoojaModel(
      id: 0,
      name: data['name'] as String? ?? '',
      description: data['desc'] as String? ?? '',
      pricePerPerson: (data['pricePerPerson'] as num?)?.toInt() ?? 0,
      colorHex: hex,
      iconName: iconName,
      duration: data['duration'] as String? ?? '',
      displayOrder: 0,
      info: data['info'] as String? ?? '',
      beforeInstructions: List<String>.from(data['beforeInstructions'] ?? []),
      afterInstructions: List<String>.from(data['afterInstructions'] ?? []),
      thingsToBring: List<String>.from(data['thingsToBring'] ?? []),
      muhurtaDates: (data['muhurtaDates'] as List?)
              ?.map((e) => DateTime.tryParse(e as String))
              .whereType<DateTime>()
              .toList() ??
          [],
      enabled: true,
    );
  }

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
      stayRatePerNight: (json['stayRatePerNight'] as num?)?.toInt() ?? 0,
      privatePooja: json['privatePooja'] as bool? ?? false,
      privatePoojaRate: (json['privatePoojaRate'] as num?)?.toInt() ?? 0,
      muhurtaDates: (json['muhurtaDates'] as List?)
              ?.map((e) => DateTime.tryParse(e as String))
              .whereType<DateTime>()
              .toList() ??
          [],
      enabled: json['enabled'] as bool? ?? true,
    );
  }
}
