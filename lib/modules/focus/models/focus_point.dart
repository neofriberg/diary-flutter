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
}
