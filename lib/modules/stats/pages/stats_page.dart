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
                title: '📊 Overview',
                child: Column(
                  children: [
                    _buildStatRow('Total sessions', '${stats.totalSessions}'),
                    const Divider(height: 1),
                    _buildStatRow('This week', '${stats.thisWeekCount}'),
                    const Divider(height: 1),
                    _buildStatRow('This month', '${stats.thisMonthCount}'),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // By Training Type
              _buildSectionCard(
                context,
                title: '🏃 By Training Type',
                child: Column(
                  children: byType.entries.map((entry) {
                    final pct = stats.totalSessions > 0
                        ? (entry.value / stats.totalSessions * 100).round()
                        : 0;
                    return _buildStatRow(entry.key, '${entry.value}  ($pct%)');
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),

              // By Focus Point
              _buildSectionCard(
                context,
                title: '🎯 By Focus Point',
                child: Column(
                  children: byFocus.entries.map((entry) {
                    return _buildStatRow(entry.key, '${entry.value}');
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),

              // Score Distributions
              _buildSectionCard(
                context,
                title: '📈 Score Distributions',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDistributionBar(
                      context,
                      label: 'Focus',
                      distribution: stats.focusScoreDistribution(),
                      color: Colors.green,
                    ),
                    const SizedBox(height: 20),
                    _buildDistributionBar(
                      context,
                      label: 'Frustration',
                      distribution: stats.frustrationScoreDistribution(),
                      color: Colors.orange,
                    ),
                    const SizedBox(height: 20),
                    _buildDistributionBar(
                      context,
                      label: 'Fatigue',
                      distribution: stats.fatigueScoreDistribution(),
                      color: Colors.redAccent,
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

  Widget _buildSectionCard(BuildContext context, {required String title, required Widget child}) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
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

  Widget _buildDistributionBar(
    BuildContext context, {
    required String label,
    required Map<int, int> distribution,
    required Color color,
  }) {
    final maxCount = distribution.values.isEmpty ? 1 : distribution.values.reduce((a, b) => a > b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(11, (score) {
            final count = distribution[score] ?? 0;
            // ignore: unused_local_variable
            final flex = maxCount == 0 ? 0 : count;
            return Expanded(
              child: Column(
                children: [
                  Container(
                    height: 24,
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    decoration: BoxDecoration(
                      color: count > 0 ? color.withValues(alpha: 0.8) : color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: Text(
                        count > 0 ? '$count' : '',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: count > 0 ? Colors.white : Colors.transparent,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$score',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }
}
