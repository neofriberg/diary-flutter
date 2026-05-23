import 'package:flutter/material.dart';

class MonthView extends StatelessWidget {
  const MonthView({super.key});

  final List<String> weekDays = const [
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
          children: weekDays
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
          child: GridView.builder(
            itemCount: 35,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
            ),
            itemBuilder: (context, index) {
              final dayNumber = index - 2;
              return Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black12),
                ),
                child: dayNumber > 0 && dayNumber <= 31
                    ? Text('$dayNumber')
                    : null,
              );
            },
          ),
        ),
      ],
    );
  }
}
