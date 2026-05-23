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

  Map<int, int> focusScoreDistribution() => _scoreDistribution((s) => s.focusScore);
  Map<int, int> frustrationScoreDistribution() => _scoreDistribution((s) => s.frustrationScore);
  Map<int, int> fatigueScoreDistribution() => _scoreDistribution((s) => s.fatigueScore);

  Map<int, int> _scoreDistribution(int? Function(TrainingSession) extractor) {
    final map = <int, int>{};
    for (final s in allSessions) {
      final score = extractor(s);
      if (score != null) {
        map[score] = (map[score] ?? 0) + 1;
      }
    }
    return map;
  }
}
