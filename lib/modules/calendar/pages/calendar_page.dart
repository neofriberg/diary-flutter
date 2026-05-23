import 'package:flutter/material.dart';

import '../widgets/month_view.dart';
import '../widgets/week_view.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  bool _showMonth = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: SegmentedButton<bool>(
              segments: const [
                ButtonSegment(
                  value: false,
                  label: Text('Week'),
                ),
                ButtonSegment(
                  value: true,
                  label: Text('Month'),
                ),
              ],
              selected: {_showMonth},
              onSelectionChanged: (selection) {
                setState(() {
                  _showMonth = selection.first;
                });
              },
            ),
          ),
        ],
      ),
      body: _showMonth ? const MonthView() : const WeekView(),
    );
  }
}
