import '../models/diary_entry.dart';

abstract class DiaryRepository {
  List<DiaryEntry> getAllEntries();
  void addEntry(DiaryEntry entry);
}

class InMemoryDiaryRepository implements DiaryRepository {
  final List<DiaryEntry> _entries = [];

  @override
  List<DiaryEntry> getAllEntries() => List.unmodifiable(_entries);

  @override
  void addEntry(DiaryEntry entry) => _entries.add(entry);
}
