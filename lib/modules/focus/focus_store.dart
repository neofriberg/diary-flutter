import 'package:flutter/material.dart';

import 'models/focus_point.dart';
import '../session/session_store.dart';

/// In-memory store for [FocusPoint] objects.
class FocusStore extends ChangeNotifier {
  final List<FocusPoint> _items = <FocusPoint>[];

  List<FocusPoint> get all => List.unmodifiable(_items);

  List<FocusPoint> get active => _items.where((e) => e.isCurrentlyActive).toList();

  Future<void> add(FocusPoint entity) async {
    _items.add(entity);
    notifyListeners();
  }

  Future<void> update(FocusPoint entity) async {
    final index = _items.indexWhere((e) => e.id == entity.id);
    if (index != -1) {
      _items[index] = entity;
      notifyListeners();
    }
  }

  Future<void> remove(String id) async {
    _items.removeWhere((e) => e.id == id);
    // Cascade: clear focusPoint on sessions referencing this id
    final sessionIds = sessionStore.all
        .where((s) => s.focusPoint?.id == id)
        .map((s) => s.id)
        .toList();
    for (final sessionId in sessionIds) {
      sessionStore.clearFocusPoint(sessionId);
    }
    notifyListeners();
  }

  FocusPoint? getById(String id) =>
      _items.cast<FocusPoint?>().firstWhere((e) => e!.id == id, orElse: () => null);

  /// Case-insensitive title uniqueness check among active focus points.
  bool titleExists(String title, {String? excludeId}) {
    final lower = title.trim().toLowerCase();
    return _items.any((e) =>
        e.isActive &&
        e.title.trim().toLowerCase() == lower &&
        e.id != excludeId);
  }
}

/// Shared singleton instance.
final FocusStore focusStore = FocusStore();
