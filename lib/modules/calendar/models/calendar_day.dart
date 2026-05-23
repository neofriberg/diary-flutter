/// Represents a single cell in the calendar grid.
class CalendarDay {
  final DateTime date;
  final bool isCurrentMonth;

  const CalendarDay({
    required this.date,
    required this.isCurrentMonth,
  });
}
