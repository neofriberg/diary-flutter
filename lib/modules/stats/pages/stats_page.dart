import 'package:flutter/material.dart';

import '../models/training_stats.dart';
import '../../session/session_store.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stats'),
      ),
      body: AnimatedBuilder(
        animation: sessionStore,
        builder: (context, _) {
          final stats = TrainingStats(allSessions: sessionStore.all);
          final byType = stats.sessionsByTrainingType();
          final byFocus = stats.sessionsByFocusPoint();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Overview
              _buildSectionCard(
                context,
                icon: Icons.bar_chart,
                title: 'Overview',
                child: Column(
                  children: [
                    _buildStatRow(Icons.event_note, 'Total sessions',
                        '${stats.totalSessions}'),
                    const Divider(height: 1),
                    _buildStatRow(Icons.date_range, 'This week',
                        '${stats.thisWeekCount}'),
                    const Divider(height: 1),
                    _buildStatRow(Icons.calendar_month, 'This month',
                        '${stats.thisMonthCount}'),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // By Training Type
              _buildSectionCard(
                context,
                icon: Icons.directions_run,
                title: 'By Training Type',
                child: Column(
                  children: byType.entries.map((entry) {
                    final pct = stats.totalSessions > 0
                        ? (entry.value / stats.totalSessions * 100).round()
                        : 0;
                    return _buildStatRow(
                      Icons.fitness_center,
                      entry.key,
                      '${entry.value}  ($pct%)',
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),

              // By Focus Point
              _buildSectionCard(
                context,
                icon: Icons.track_changes,
                title: 'By Focus Point',
                child: Column(
                  children: byFocus.entries.map((entry) {
                    return _buildStatRow(
                      Icons.flag,
                      entry.key,
                      '${entry.value}',
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),

              // Averages & Standard Deviations
              _buildSectionCard(
                context,
                icon: Icons.analytics,
                title: 'Score Averages',
                child: Column(
                  children: [
                    _buildScoreRow(
                      context,
                      icon: Icons.psychology,
                      label: 'Focus',
                      color: Colors.green,
                      result: stats.avgFocusScore,
                    ),
                    const Divider(height: 1),
                    _buildScoreRow(
                      context,
                      icon: Icons.whatshot,
                      label: 'Frustration',
                      color: Colors.orange,
                      result: stats.avgFrustrationScore,
                    ),
                    const Divider(height: 1),
                    _buildScoreRow(
                      context,
                      icon: Icons.battery_unknown,
                      label: 'Fatigue',
                      color: Colors.redAccent,
                      result: stats.avgFatigueScore,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 15),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required ({double avg, double std})? result,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 15),
            ),
          ),
          if (result == null)
            Text(
              'No data',
              style: TextStyle(fontSize: 13, color: Colors.grey[400]),
            )
          else
            Text(
              '${result.avg.toStringAsFixed(1)} ± ${result.std.toStringAsFixed(1)}',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
        ],
      ),
    );
  }
}
