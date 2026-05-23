import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../session/session_store.dart';
import '../../session/models/training_session.dart';
import '../models/calendar_day.dart';

class MonthView extends StatefulWidget {
  const MonthView({super.key});

  @override
  State<MonthView> createState() => _MonthViewState();
}

class _MonthViewState extends State<MonthView> {
  late DateTime _focusedMonth;
  final DateTime _today = DateTime.now();

  final List<String> _weekDays = const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  void initState() {
    super.initState();
    _focusedMonth = DateTime(_today.year, _today.month);
  }

  void _previousMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
    });
  }

  void _goToToday() {
    setState(() {
      _focusedMonth = DateTime(_today.year, _today.month);
    });
  }

  List<CalendarDay> _buildCalendarDays() {
    final firstOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final daysInMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;

    final firstWeekday = firstOfMonth.weekday;
    final leadingDays = firstWeekday - 1;

    final totalCells = ((leadingDays + daysInMonth) / 7).ceil() * 7;

    final List<CalendarDay> days = [];

    final prevMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
    final daysInPrevMonth = DateTime(prevMonth.year, prevMonth.month + 1, 0).day;
    for (int i = leadingDays - 1; i >= 0; i--) {
      days.add(CalendarDay(
        date: DateTime(prevMonth.year, prevMonth.month, daysInPrevMonth - i),
        isCurrentMonth: false,
      ));
    }

    for (int day = 1; day <= daysInMonth; day++) {
      days.add(CalendarDay(
        date: DateTime(_focusedMonth.year, _focusedMonth.month, day),
        isCurrentMonth: true,
      ));
    }

    final trailingDays = totalCells - days.length;
    final nextMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
    for (int i = 1; i <= trailingDays; i++) {
      days.add(CalendarDay(
        date: DateTime(nextMonth.year, nextMonth.month, i),
        isCurrentMonth: false,
      ));
    }

    return days;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  List<TrainingSession> _sessionsForDay(DateTime day) {
    return sessionStore.forDate(day);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final calendarDays = _buildCalendarDays();
    final monthTitle = DateFormat('MMMM yyyy').format(_focusedMonth);
    final isCurrentMonth = _focusedMonth.year == _today.year && _focusedMonth.month == _today.month;

    return AnimatedBuilder(
      animation: sessionStore,
      builder: (context, _) {
        return Column(
          children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: _previousMonth,
                icon: const Icon(Icons.chevron_left),
                tooltip: 'Previous month',
              ),
              Column(
                children: [
                  Text(
                    monthTitle,
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (!isCurrentMonth)
                    GestureDetector(
                      onTap: _goToToday,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          'Go to today',
                          style: textTheme.labelSmall?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              IconButton(
                onPressed: _nextMonth,
                icon: const Icon(Icons.chevron_right),
                tooltip: 'Next month',
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: _weekDays
                .map(
                  (day) => Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        day,
                        style: textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Colors.grey[600],
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        const Divider(height: 1, indent: 12, endIndent: 12),
        const SizedBox(height: 4),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final rows = (calendarDays.length / 7).ceil();
                final cellHeight = (constraints.maxHeight / rows).floorToDouble();

                return GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: calendarDays.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    mainAxisExtent: cellHeight - 6,
                  ),
                  itemBuilder: (context, index) {
                    final day = calendarDays[index];
                    final isToday = _isSameDay(day.date, _today);
                    final sessions = _sessionsForDay(day.date);
                    final hasSessions = sessions.isNotEmpty;

                    return Padding(
                      padding: const EdgeInsets.all(3),
                      child: Material(
                        color: day.isCurrentMonth
                            ? (isToday
                                ? colorScheme.primaryContainer.withValues(alpha: 0.35)
                                : Colors.white)
                            : Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: hasSessions ? () => _showDaySessions(context, day.date, sessions) : null,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: isToday
                                  ? Border.all(
                                      color: colorScheme.primary,
                                      width: 2,
                                    )
                                  : Border.all(
                                      color: Colors.grey[200]!,
                                      width: 0.5,
                                    ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(8, 6, 0, 0),
                                    child: Text(
                                      '${day.date.day}',
                                      style: textTheme.bodySmall?.copyWith(
                                        fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                                        color: isToday
                                            ? colorScheme.primary
                                            : (day.isCurrentMonth
                                                ? Colors.grey[850]
                                                : Colors.grey[400]),
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (hasSessions)
                                        ...sessions.take(3).map((_) {
                                          return Container(
                                            width: 5,
                                            height: 5,
                                            margin: const EdgeInsets.symmetric(horizontal: 1.5),
                                            decoration: BoxDecoration(
                                              color: colorScheme.primary,
                                              shape: BoxShape.circle,
                                            ),
                                          );
                                        })
                                      else
                                        const SizedBox(height: 5),
                                      if (sessions.length > 3)
                                        Container(
                                          width: 5,
                                          height: 5,
                                          margin: const EdgeInsets.symmetric(horizontal: 1.5),
                                          decoration: BoxDecoration(
                                            color: colorScheme.primary.withValues(alpha: 0.4),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  },
);
}

void _showDaySessions(BuildContext context, DateTime date, List<TrainingSession> sessions) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    DateFormat('EEEE, d MMMM').format(date),
                    style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${sessions.length} session${sessions.length > 1 ? 's' : ''}',
                    style: textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 8),
                  ...sessions.map((session) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Card(
                        elevation: 2,
                        shadowColor: Colors.black12,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: colorScheme.primary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      session.title,
                                      style: textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  if (session.trainingType != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: colorScheme.primaryContainer.withValues(alpha: 0.5),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        session.trainingType!.name,
                                        style: textTheme.labelSmall?.copyWith(
                                          color: colorScheme.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                session.description,
                                style: textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}


