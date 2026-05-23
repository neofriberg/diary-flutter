/// Represents a single training / workout session.
///
/// Captures the core metadata (title, sport, date, description) alongside
/// optional self-assessment scores and reflective notes.
class TrainingSession {
  final String id;

  /// Short title of the session, e.g. "Morning HIIT".
  final String title;

  /// Sport or activity type, e.g. "Running", "Swimming", "Strength".
  final String sportType;

  /// The calendar date on which the session took place.
  final DateTime date;

  /// Free-form description of what was done.
  final String description;

  /// The athlete's main focus point for this session.
  final String? focusPoint;

  /// Self-rated focus quality, 0–10.
  final int? focusScore;

  /// Self-rated frustration level, 0–10.
  final int? frustrationScore;

  /// Self-rated fatigue level, 0–10.
  final int? fatigueScore;

  /// Any additional reflective notes.
  final String? notes;

  /// When this record was created in the app.
  final DateTime createdAt;

  /// When this record was last updated.
  final DateTime? updatedAt;

  const TrainingSession({
    required this.id,
    required this.title,
    required this.sportType,
    required this.date,
    required this.description,
    this.focusPoint,
    this.focusScore,
    this.frustrationScore,
    this.fatigueScore,
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });
}
