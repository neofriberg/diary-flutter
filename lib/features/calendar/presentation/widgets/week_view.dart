import 'package:flutter/material.dart';

class WeekView extends StatelessWidget {
  const WeekView({super.key});

  final List<String> days = const [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: days
              .map(
                (day) => Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      day,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const Divider(height: 1),
        Expanded(
          child: Row(
            children: List.generate(
              7,
              (index) => Expanded(
                child: Container(
                  alignment: Alignment.topCenter,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border(
                      right: index < 6
                          ? const BorderSide(color: Colors.black12)
                          : BorderSide.none,
                    ),
                  ),
                  child: Text('${index + 1}'),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
