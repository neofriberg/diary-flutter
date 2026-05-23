/// Aggregated stats for a week of training.
class WeeklySummary {
  final DateTime weekStart;
  final int totalSessions;
  final double avgFocusScore;
  final double avgFatigueScore;
  final double avgFrustrationScore;

  const WeeklySummary({
    required this.weekStart,
    required this.totalSessions,
    required this.avgFocusScore,
    required this.avgFatigueScore,
    required this.avgFrustrationScore,
  });
}
