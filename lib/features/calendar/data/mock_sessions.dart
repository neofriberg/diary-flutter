import '../../diary/data/models/diary_entry.dart';

final List<DiaryEntry> mockSessions = [
  DiaryEntry(
    id: '1',
    title: 'Morning Jog',
    content: 'Ran 5km around the park. Felt energised and the weather was perfect.',
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
  ),
  DiaryEntry(
    id: '2',
    title: 'Project Planning',
    content: 'Outlined the Q3 roadmap with the team. Key focus on mobile performance.',
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
  ),
  DiaryEntry(
    id: '3',
    title: 'Guitar Practice',
    content: 'Practised the new chord progression for 45 minutes. Getting smoother!',
    createdAt: DateTime.now().subtract(const Duration(days: 3)),
  ),
  DiaryEntry(
    id: '4',
    title: 'Reading',
    content: 'Finished chapter 7 of "Atomic Habits". Lots of great takeaways.',
    createdAt: DateTime.now().subtract(const Duration(days: 4)),
  ),
  DiaryEntry(
    id: '5',
    title: 'Meditation',
    content: '20-minute guided session. Mind felt calm and focused afterwards.',
    createdAt: DateTime.now(),
  ),
];
