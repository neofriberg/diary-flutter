import 'package:flutter/material.dart';

/// A user-defined sport or activity category.
class TrainingType {
  final String id;
  final String name;
  final int? iconCodePoint;
  final int? color;
  final DateTime createdAt;

  const TrainingType({
    required this.id,
    required this.name,
    this.iconCodePoint,
    this.color,
    required this.createdAt,
  });

  /// Deserialize icon for UI consumption.
  IconData? get icon => iconCodePoint != null
      ? IconData(iconCodePoint!, fontFamily: 'MaterialIcons')
      : null;

  TrainingType copyWith({
    String? id,
    String? name,
    int? iconCodePoint,
    int? color,
    DateTime? createdAt,
  }) {
    return TrainingType(
      id: id ?? this.id,
      name: name ?? this.name,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'iconCodePoint': iconCodePoint,
        'color': color,
        'createdAt': createdAt.toIso8601String(),
      };

  factory TrainingType.fromJson(Map<String, dynamic> json) {
    return TrainingType(
      id: json['id'] as String,
      name: json['name'] as String,
      iconCodePoint: json['iconCodePoint'] as int?,
      color: json['color'] as int?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
