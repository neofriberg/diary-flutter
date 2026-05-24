const int kDefaultFocusColor = 0xFF1E88E5; // Material Blue 600

/// A goal or theme a user wants to work on over a defined period.
class FocusPoint {
  final String id;
  final String title;
  final String? description;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final int? color;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const FocusPoint({
    required this.id,
    required this.title,
    this.description,
    required this.startDate,
    required this.endDate,
    this.isActive = true,
    this.color,
    required this.createdAt,
    this.updatedAt,
  });

  /// True if the focus point spans the current date and is active.
  bool get isCurrentlyActive {
    final now = DateTime.now();
    return isActive &&
        now.isAfter(startDate.subtract(const Duration(days: 1))) &&
        now.isBefore(endDate.add(const Duration(days: 1)));
  }

  /// True if the focus point is active on the given [date].
  bool isActiveOn(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    return isActive &&
        !d.isBefore(DateTime(startDate.year, startDate.month, startDate.day)) &&
        !d.isAfter(DateTime(endDate.year, endDate.month, endDate.day));
  }

  FocusPoint copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    int? color,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FocusPoint(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'isActive': isActive,
        'color': color,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  factory FocusPoint.fromJson(Map<String, dynamic> json) {
    return FocusPoint(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      isActive: json['isActive'] as bool? ?? true,
      color: json['color'] as int?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }
}
