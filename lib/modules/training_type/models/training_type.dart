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
}
