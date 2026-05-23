import 'package:flutter/material.dart';

import 'models/training_session.dart';

/// Lightweight in-memory store for training sessions.
class SessionStore extends ChangeNotifier {
  final List<TrainingSession> _entries = <TrainingSession>[];

  List<TrainingSession> get all => List.unmodifiable(_entries);

  List<TrainingSession> forDate(DateTime date) {
    return _entries.where((s) {
      return s.date.year == date.year &&
          s.date.month == date.month &&
          s.date.day == date.day;
    }).toList();
  }

  void add(TrainingSession session) {
    _entries.add(session);
    notifyListeners();
  }

  void remove(String id) {
    _entries.removeWhere((s) => s.id == id);
    notifyListeners();
  }

  void update(TrainingSession session) {
    final index = _entries.indexWhere((s) => s.id == session.id);
    if (index != -1) {
      _entries[index] = session;
      notifyListeners();
    }
  }

  /// Cascade helper: clears trainingType on a session (used by TrainingTypeStore).
  void clearTrainingType(String sessionId) {
    final index = _entries.indexWhere((s) => s.id == sessionId);
    if (index != -1) {
      _entries[index] = _entries[index].copyWith(trainingType: null);
      notifyListeners();
    }
  }

  /// Cascade helper: clears focusPoint on a session (used by FocusStore).
  void clearFocusPoint(String sessionId) {
    final index = _entries.indexWhere((s) => s.id == sessionId);
    if (index != -1) {
      _entries[index] = _entries[index].copyWith(focusPoint: null);
      notifyListeners();
    }
  }
}

/// Shared singleton instance used across the app.
final SessionStore sessionStore = SessionStore();
