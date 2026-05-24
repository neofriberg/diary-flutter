import 'dart:convert';
import 'package:flutter/material.dart';

import '../../core/database/database_service.dart';
import 'models/focus_point.dart';
import '../session/session_store.dart';

/// In-memory store for [FocusPoint] objects with local Hive persistence.
class FocusStore extends ChangeNotifier {
  final List<FocusPoint> _items = <FocusPoint>[];

  List<FocusPoint> get all => List.unmodifiable(_items);

  List<FocusPoint> get active =>
      _items.where((e) => e.isCurrentlyActive).toList();

  Future<void> load() async {
    final box = DatabaseService.instance.focusBox;
    _items.clear();
    for (final raw in box.values) {
      _items.add(FocusPoint.fromJson(jsonDecode(raw)));
    }
    notifyListeners();
  }

  Future<void> _saveItem(FocusPoint entity) async {
    await DatabaseService.instance.focusBox
        .put(entity.id, jsonEncode(entity.toJson()));
  }

  Future<void> add(FocusPoint entity) async {
    await _saveItem(entity);
    _items.add(entity);
    notifyListeners();
  }

  Future<void> update(FocusPoint entity) async {
    await _saveItem(entity);
    final index = _items.indexWhere((e) => e.id == entity.id);
    if (index != -1) {
      _items[index] = entity;
      notifyListeners();
    }
  }

  Future<void> remove(String id) async {
    await DatabaseService.instance.focusBox.delete(id);
    _items.removeWhere((e) => e.id == id);
    // Cascade: clear focusPoint on sessions referencing this id
    final sessionIds = sessionStore.all
        .where((s) => s.focusPoint?.id == id)
        .map((s) => s.id)
        .toList();
    for (final sessionId in sessionIds) {
      await sessionStore.clearFocusPoint(sessionId);
    }
    notifyListeners();
  }

  FocusPoint? getById(String id) => _items
      .cast<FocusPoint?>()
      .firstWhere((e) => e!.id == id, orElse: () => null);

  /// Case-insensitive title uniqueness check among active focus points.
  bool titleExists(String title, {String? excludeId}) {
    final lower = title.trim().toLowerCase();
    return _items.any((e) =>
        e.isActive &&
        e.title.trim().toLowerCase() == lower &&
        e.id != excludeId);
  }

  /// Returns all focus points active on the given [date].
  List<FocusPoint> activeOn(DateTime date) =>
      _items.where((e) => e.isActiveOn(date)).toList();
}

/// Shared singleton instance.
final FocusStore focusStore = FocusStore();
