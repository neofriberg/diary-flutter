import '../../training_type/models/training_type.dart';
import '../../focus/models/focus_point.dart';

class TrainingSession {
  final String id;
  final String title;
  final TrainingType? trainingType;
  final DateTime date;
  final DateTime? startTime;
  final Duration? duration;
  final String description;
  final FocusPoint? focusPoint;
  final int? focusScore;
  final int? frustrationScore;
  final int? fatigueScore;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const TrainingSession({
    required this.id,
    required this.title,
    this.trainingType,
    required this.date,
    this.startTime,
    this.duration,
    required this.description,
    this.focusPoint,
    this.focusScore,
    this.frustrationScore,
    this.fatigueScore,
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  TrainingSession copyWith({
    String? id,
    String? title,
    TrainingType? trainingType,
    DateTime? date,
    DateTime? startTime,
    Duration? duration,
    String? description,
    FocusPoint? focusPoint,
    int? focusScore,
    int? frustrationScore,
    int? fatigueScore,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TrainingSession(
      id: id ?? this.id,
      title: title ?? this.title,
      trainingType: trainingType ?? this.trainingType,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      duration: duration ?? this.duration,
      description: description ?? this.description,
      focusPoint: focusPoint ?? this.focusPoint,
      focusScore: focusScore ?? this.focusScore,
      frustrationScore: frustrationScore ?? this.frustrationScore,
      fatigueScore: fatigueScore ?? this.fatigueScore,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
