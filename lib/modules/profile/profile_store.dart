import 'dart:convert';
import 'package:flutter/material.dart';

import '../../core/database/database_service.dart';
import 'models/user_profile.dart';

/// Store for the single user profile with local Hive persistence.
class ProfileStore extends ChangeNotifier {
  UserProfile? _profile;

  UserProfile? get profile => _profile;

  Future<void> load() async {
    final raw = DatabaseService.instance.profileBox.get('profile');
    if (raw != null) {
      _profile = UserProfile.fromJson(jsonDecode(raw));
    }
    notifyListeners();
  }

  Future<void> save(UserProfile profile) async {
    _profile = profile;
    await DatabaseService.instance.profileBox
        .put('profile', jsonEncode(profile.toJson()));
    notifyListeners();
  }
}

/// Shared singleton instance.
final ProfileStore profileStore = ProfileStore();
