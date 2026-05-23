import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/mock_sessions.dart';

class WeekView extends StatelessWidget {
  const WeekView({super.key});

  List<DateTime> _getCurrentWeekDates() {
    final now = DateTime.now();
    final weekday = now.weekday; // Monday = 1, Sunday = 7
    final monday = now.subtract(Duration(days: weekday - 1));
    return List.generate(7, (index) => monday.add(Duration(days: index)));
  }

  String _dayName(DateTime date) {
    return DateFormat('EEEE').format(date); // Monday, Tuesday, ...
  }

  String _dateTitle(DateTime date) {
    return DateFormat('d MMMM').format(date); // 23 May
  }

  @override
  Widget build(BuildContext context) {
    final weekDates = _getCurrentWeekDates();
    final today = DateTime.now();

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: weekDates.length,
      separatorBuilder: (_, __) => const SizedBox(height: 20),
      itemBuilder: (context, index) {
        final date = weekDates[index];
        final isToday = date.year == today.year &&
            date.month == today.month &&
            date.day == today.day;

        // Distribute mock sessions across the week for demo purposes
        final session = index < mockSessions.length ? mockSessions[index] : null;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Day header: bold day name + date
            Row(
              children: [
                Text(
                  _dayName(date),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isToday
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ),
                ),
                const SizedBox(width: 8),
                Text(
                  _dateTitle(date),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: isToday
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey[600],
                      ),
                ),
                if (isToday) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Today',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            // Hovering card with session
            if (session != null)
              Card(
                elevation: 4,
                shadowColor: Colors.black26,
                surfaceTintColor: Colors.white,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.title,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        session.content,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[700],
                            ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Card(
                elevation: 2,
                shadowColor: Colors.black12,
                surfaceTintColor: Colors.white,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'No sessions',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[400],
                          fontStyle: FontStyle.italic,
                        ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
