import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../session/session_store.dart';
import '../../session/models/training_session.dart';

class WeekView extends StatefulWidget {
  const WeekView({super.key});

  @override
  State<WeekView> createState() => _WeekViewState();
}

class _WeekViewState extends State<WeekView> {
  final Set<String> _expandedIds = {};
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _todayKey = GlobalKey();
  int _weekOffset = 0;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  List<DateTime> _getWeekDates() {
    final now = DateTime.now();
    final weekday = now.weekday;
    final monday = now.subtract(Duration(days: weekday - 1));
    final anchor = monday.add(Duration(days: _weekOffset * 7));
    return List.generate(7, (index) => anchor.add(Duration(days: index)));
  }

  String _dayName(DateTime date) {
    return DateFormat('EEEE').format(date);
  }

  String _dateTitle(DateTime date) {
    return DateFormat('d MMMM').format(date);
  }

  String _weekRangeLabel(List<DateTime> weekDates) {
    final start = weekDates.first;
    final end = weekDates.last;
    final sameMonth = start.month == end.month;
    if (sameMonth) {
      return '${DateFormat('d').format(start)} – ${DateFormat('d MMMM y').format(end)}';
    }
    return '${DateFormat('d MMM').format(start)} – ${DateFormat('d MMM y').format(end)}';
  }

  List<TrainingSession> _sessionsForDate(DateTime date) {
    return sessionStore.forDate(date);
  }

  void _toggleSession(String id) {
    setState(() {
      if (_expandedIds.contains(id)) {
        _expandedIds.remove(id);
      } else {
        _expandedIds.add(id);
      }
    });
  }

  void _changeWeek(int delta) {
    setState(() {
      _weekOffset += delta;
      _expandedIds.clear();
    });
    if (_weekOffset == 0) {
      _scrollToToday();
    }
  }

  void _scrollToToday() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = _todayKey.currentContext;
      if (context != null) {
        Scrollable.ensureVisible(
          context,
          alignment: 0.4,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void initState() {
    super.initState();
    if (_weekOffset == 0) {
      _scrollToToday();
    }
  }

  Widget _buildScoreBar(
    BuildContext context,
    String label,
    int score,
    Color color,
  ) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
              ),
              Text(
                '$score/10',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: score / 10,
              minHeight: 6,
              backgroundColor: color.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final weekDates = _getWeekDates();
    final today = DateTime.now();

    final dayWidgets = weekDates.asMap().entries.map((entry) {
      final index = entry.key;
      final date = entry.value;
      final isToday = date.year == today.year &&
          date.month == today.month &&
          date.day == today.day;

      final sessions = _sessionsForDate(date);

      Widget dayColumn = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          if (sessions.isNotEmpty)
            Column(
              children: sessions.map((session) {
                final isExpanded = _expandedIds.contains(session.id);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: GestureDetector(
                    onTap: () => _toggleSession(session.id),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            if (session.trainingType != null)
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 3),
                                                margin: const EdgeInsets.only(
                                                    right: 8),
                                                decoration: BoxDecoration(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primaryContainer,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  session.trainingType!.name,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .labelSmall
                                                      ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Theme.of(
                                                                context)
                                                            .colorScheme
                                                            .onPrimaryContainer,
                                                      ),
                                                ),
                                              ),
                                            Expanded(
                                              child: Text(
                                                session.title,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleMedium
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (session.focusPoint != null) ...[
                                          const SizedBox(height: 8),
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Icon(
                                                Icons.center_focus_strong,
                                                size: 16,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                              ),
                                              const SizedBox(width: 6),
                                              Expanded(
                                                child: Text(
                                                  session.focusPoint!.title,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall
                                                      ?.copyWith(
                                                        color:
                                                            Theme.of(context)
                                                                .colorScheme
                                                                .primary,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        height: 1.3,
                                                      ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                        const SizedBox(height: 6),
                                        Text(
                                          session.description,
                                          maxLines: isExpanded ? null : 2,
                                          overflow: isExpanded
                                              ? TextOverflow.visible
                                              : TextOverflow.ellipsis,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                color: Colors.grey[700],
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  AnimatedRotation(
                                    turns: isExpanded ? 0.5 : 0,
                                    duration:
                                        const Duration(milliseconds: 250),
                                    child: Icon(
                                      Icons.keyboard_arrow_down,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            AnimatedCrossFade(
                              firstChild: const SizedBox.shrink(),
                              secondChild:
                                  _buildExpandedDetails(context, session),
                              crossFadeState: isExpanded
                                  ? CrossFadeState.showSecond
                                  : CrossFadeState.showFirst,
                              duration: const Duration(milliseconds: 250),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            )
          else
            Card(
              elevation: 0,
              color: Colors.grey[50],
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

      if (isToday) {
        dayColumn = Container(key: _todayKey, child: dayColumn);
      }

      return Padding(
        padding: EdgeInsets.only(
          bottom: index < weekDates.length - 1 ? 20 : 0,
        ),
        child: dayColumn,
      );
    }).toList();

    return AnimatedBuilder(
      animation: sessionStore,
      builder: (context, _) {
        return ListView(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => _changeWeek(-1),
                icon: const Icon(Icons.chevron_left),
                tooltip: 'Previous week',
                style: IconButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.surface,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _weekRangeLabel(weekDates),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  if (_weekOffset == 0)
                    Text(
                      'This week',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                ],
              ),
              IconButton(
                onPressed: () => _changeWeek(1),
                icon: const Icon(Icons.chevron_right),
                tooltip: 'Next week',
                style: IconButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.surface,
                ),
              ),
            ],
          ),
        ),
            ...dayWidgets,
          ],
        );
      },
    );
  }

  Widget _buildExpandedDetails(BuildContext context, TrainingSession session) {
    final focus = session.focusScore ?? 0;
    final frustration = session.frustrationScore ?? 0;
    final fatigue = session.fatigueScore ?? 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 1),
          const SizedBox(height: 12),
          if (session.focusPoint != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.center_focus_strong,
                    size: 16,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      session.focusPoint!.title,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
                            fontWeight: FontWeight.w600,
                            height: 1.35,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              _buildScoreBar(
                context,
                'Focus on point',
                focus,
                Colors.green,
              ),
              const SizedBox(width: 12),
              _buildScoreBar(
                context,
                'Frustration',
                frustration,
                Colors.orange,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildScoreBar(
                context,
                'Fatigue',
                fatigue,
                Colors.redAccent,
              ),
            ],
          ),
          if (session.notes != null && session.notes!.isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Notes',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    session.notes!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[700],
                          height: 1.4,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
