import 'dart:math';

import '../../session/models/training_session.dart';

/// Lightweight helper class for computing training statistics.
class TrainingStats {
  final List<TrainingSession> allSessions;

  TrainingStats({required this.allSessions});

  int get totalSessions => allSessions.length;

  int get thisWeekCount {
    final now = DateTime.now();
    final weekday = now.weekday;
    final monday = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: weekday - 1));
    final sunday = monday.add(const Duration(days: 6));
    return allSessions.where((s) {
      final d = DateTime(s.date.year, s.date.month, s.date.day);
      return !d.isBefore(monday) && !d.isAfter(sunday);
    }).length;
  }

  int get thisMonthCount {
    final now = DateTime.now();
    return allSessions.where((s) {
      return s.date.year == now.year && s.date.month == now.month;
    }).length;
  }

  Map<String, int> sessionsByTrainingType() {
    final map = <String, int>{};
    for (final s in allSessions) {
      final key = s.trainingType?.name ?? 'Uncategorised';
      map[key] = (map[key] ?? 0) + 1;
    }
    return map;
  }

  Map<String, int> sessionsByFocusPoint() {
    final map = <String, int>{};
    for (final s in allSessions) {
      final key = s.focusPoint?.title ?? 'No focus';
      map[key] = (map[key] ?? 0) + 1;
    }
    return map;
  }

  // Reusable helpers for mean & standard deviation
  ({double avg, double std})? _avgAndStd(int? Function(TrainingSession) extractor) {
    final scores = allSessions.map(extractor).whereType<int>().toList();
    if (scores.isEmpty) return null;
    final sum = scores.fold<int>(0, (a, b) => a + b);
    final mean = sum / scores.length;
    final variance =
        scores.fold<double>(0, (a, b) => a + (b - mean) * (b - mean)) /
            scores.length;
    final std = variance.isNaN || variance.isInfinite || variance <= 0
        ? 0.0
        : sqrt(variance);
    return (avg: mean, std: std);
  }

  ({double avg, double std})? get avgFocusScore => _avgAndStd((s) => s.focusScore);

  ({double avg, double std})? get avgFrustrationScore =>
      _avgAndStd((s) => s.frustrationScore);

  ({double avg, double std})? get avgFatigueScore => _avgAndStd((s) => s.fatigueScore);
}
