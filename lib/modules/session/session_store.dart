import 'models/training_session.dart';
import 'mock/mock_sessions.dart';

/// Lightweight in-memory store for training sessions.
///
/// Pre-loaded with [mockSessions] for demo purposes.
class SessionStore {
  final List<TrainingSession> _entries = List.from(mockSessions);

  List<TrainingSession> get all => List.unmodifiable(_entries);

  List<TrainingSession> forDate(DateTime date) {
    return _entries.where((s) {
      return s.date.year == date.year &&
          s.date.month == date.month &&
          s.date.day == date.day;
    }).toList();
  }

  void add(TrainingSession session) => _entries.add(session);

  void remove(String id) => _entries.removeWhere((s) => s.id == id);
}

/// Shared singleton instance used across the app.
final SessionStore sessionStore = SessionStore();
