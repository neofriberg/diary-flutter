import 'dart:convert';
import 'package:flutter/material.dart';

import '../../core/database/database_service.dart';
import 'models/training_session.dart';

/// Lightweight store for training sessions with local Hive persistence.
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

  /// Load sessions from disk.
  Future<void> load() async {
    final box = DatabaseService.instance.sessionBox;
    _entries.clear();
    for (final raw in box.values) {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      _entries.add(TrainingSession.fromJson(json));
    }
    notifyListeners();
  }

  Future<void> _saveEntry(TrainingSession session) async {
    await DatabaseService.instance.sessionBox
        .put(session.id, jsonEncode(session.toJson()));
  }

  Future<void> add(TrainingSession session) async {
    await _saveEntry(session);
    _entries.add(session);
    notifyListeners();
  }

  Future<void> remove(String id) async {
    await DatabaseService.instance.sessionBox.delete(id);
    _entries.removeWhere((s) => s.id == id);
    notifyListeners();
  }

  Future<void> update(TrainingSession session) async {
    await _saveEntry(session);
    final index = _entries.indexWhere((s) => s.id == session.id);
    if (index != -1) {
      _entries[index] = session;
      notifyListeners();
    }
  }

  /// Cascade helper: clears trainingType on a session (used by TrainingTypeStore).
  Future<void> clearTrainingType(String sessionId) async {
    final index = _entries.indexWhere((s) => s.id == sessionId);
    if (index != -1) {
      _entries[index] = _entries[index].copyWith(trainingTypeId: null);
      await _saveEntry(_entries[index]);
      notifyListeners();
    }
  }

  /// Cascade helper: clears focusPoint on a session (used by FocusStore).
  Future<void> clearFocusPoint(String sessionId) async {
    final index = _entries.indexWhere((s) => s.id == sessionId);
    if (index != -1) {
      _entries[index] = _entries[index].copyWith(focusPointId: null);
      await _saveEntry(_entries[index]);
      notifyListeners();
    }
  }
}

/// Shared singleton instance used across the app.
final SessionStore sessionStore = SessionStore();
