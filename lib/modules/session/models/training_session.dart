import '../../training_type/training_type_store.dart';
import '../../focus/focus_store.dart';
import '../../training_type/models/training_type.dart';
import '../../focus/models/focus_point.dart';

class TrainingSession {
  final String id;
  final String title;
  final String? trainingTypeId;
  final String? focusPointId;
  final DateTime date;
  final DateTime? startTime;
  final Duration? duration;
  final String description;
  final int? focusScore;
  final int? frustrationScore;
  final int? fatigueScore;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  /// Runtime-resolved reference via the global [TrainingTypeStore].
  TrainingType? get trainingType =>
      trainingTypeId != null ? trainingTypeStore.getById(trainingTypeId!) : null;

  /// Runtime-resolved reference via the global [FocusStore].
  FocusPoint? get focusPoint =>
      focusPointId != null ? focusStore.getById(focusPointId!) : null;

  const TrainingSession({
    required this.id,
    required this.title,
    this.trainingTypeId,
    this.focusPointId,
    required this.date,
    this.startTime,
    this.duration,
    required this.description,
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
    String? trainingTypeId,
    String? focusPointId,
    DateTime? date,
    DateTime? startTime,
    Duration? duration,
    String? description,
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
      trainingTypeId: trainingTypeId ?? this.trainingTypeId,
      focusPointId: focusPointId ?? this.focusPointId,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      duration: duration ?? this.duration,
      description: description ?? this.description,
      focusScore: focusScore ?? this.focusScore,
      frustrationScore: frustrationScore ?? this.frustrationScore,
      fatigueScore: fatigueScore ?? this.fatigueScore,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'trainingTypeId': trainingTypeId,
        'focusPointId': focusPointId,
        'date': date.toIso8601String(),
        'startTime': startTime?.toIso8601String(),
        'durationSeconds': duration?.inSeconds,
        'description': description,
        'focusScore': focusScore,
        'frustrationScore': frustrationScore,
        'fatigueScore': fatigueScore,
        'notes': notes,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  factory TrainingSession.fromJson(Map<String, dynamic> json) {
    return TrainingSession(
      id: json['id'] as String,
      title: json['title'] as String,
      trainingTypeId: json['trainingTypeId'] as String?,
      focusPointId: json['focusPointId'] as String?,
      date: DateTime.parse(json['date'] as String),
      startTime: json['startTime'] != null
          ? DateTime.parse(json['startTime'] as String)
          : null,
      duration: json['durationSeconds'] != null
          ? Duration(seconds: json['durationSeconds'] as int)
          : null,
      description: json['description'] as String,
      focusScore: json['focusScore'] as int?,
      frustrationScore: json['frustrationScore'] as int?,
      fatigueScore: json['fatigueScore'] as int?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }
}
