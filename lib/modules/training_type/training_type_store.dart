import 'dart:convert';
import 'package:flutter/material.dart';

import '../../core/database/database_service.dart';
import 'models/training_type.dart';
import '../session/session_store.dart';

/// In-memory store for [TrainingType] objects with local Hive persistence.
class TrainingTypeStore extends ChangeNotifier {
  final List<TrainingType> _items = <TrainingType>[];

  List<TrainingType> get all => List.unmodifiable(_items);

  Future<void> load() async {
    final box = DatabaseService.instance.trainingTypeBox;
    _items.clear();
    for (final raw in box.values) {
      _items.add(TrainingType.fromJson(jsonDecode(raw)));
    }
    notifyListeners();
  }

  Future<void> _saveItem(TrainingType entity) async {
    await DatabaseService.instance.trainingTypeBox
        .put(entity.id, jsonEncode(entity.toJson()));
  }

  Future<void> add(TrainingType entity) async {
    await _saveItem(entity);
    _items.add(entity);
    notifyListeners();
  }

  Future<void> update(TrainingType entity) async {
    await _saveItem(entity);
    final index = _items.indexWhere((e) => e.id == entity.id);
    if (index != -1) {
      _items[index] = entity;
      notifyListeners();
    }
  }

  Future<void> remove(String id) async {
    await DatabaseService.instance.trainingTypeBox.delete(id);
    _items.removeWhere((e) => e.id == id);
    // Cascade: clear trainingType on sessions referencing this id
    final sessionIds = sessionStore.all
        .where((s) => s.trainingType?.id == id)
        .map((s) => s.id)
        .toList();
    for (final sessionId in sessionIds) {
      await sessionStore.clearTrainingType(sessionId);
    }
    notifyListeners();
  }

  TrainingType? getById(String id) => _items
      .cast<TrainingType?>()
      .firstWhere((e) => e!.id == id, orElse: () => null);

  /// Case-insensitive name uniqueness check among existing items.
  bool nameExists(String name, {String? excludeId}) {
    final lower = name.trim().toLowerCase();
    return _items.any((e) =>
        e.name.trim().toLowerCase() == lower && e.id != excludeId);
  }
}

/// Shared singleton instance.
final TrainingTypeStore trainingTypeStore = TrainingTypeStore();
