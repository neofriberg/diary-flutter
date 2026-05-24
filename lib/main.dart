import 'package:flutter/material.dart';

import 'app.dart';
import 'core/database/database_service.dart';
import 'core/utils/id_generator.dart';
import 'modules/focus/focus_store.dart';
import 'modules/profile/profile_store.dart';
import 'modules/session/session_store.dart';
import 'modules/profile/models/user_profile.dart';
import 'modules/training_type/models/training_type.dart';
import 'modules/training_type/training_type_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Open all Hive boxes.
  await DatabaseService.instance.init();

  // 2. Load training types and seed defaults on first launch.
  await trainingTypeStore.load();
  if (trainingTypeStore.all.isEmpty) {
    await _seedDefaultTrainingTypes();
  }

  // 3. Load focus points.
  await focusStore.load();

  // 4. Load profile (or create a default one).
  await profileStore.load();
  if (profileStore.profile == null) {
    await profileStore.save(
      const UserProfile(id: 'default', displayName: 'Athlete'),
    );
  }

  // 5. Load sessions (type/focus references resolve at runtime via getters).
  await sessionStore.load();

  runApp(const MyApp());
}

/// Seeds a sensible set of default training types so the user can start
/// adding sessions immediately without creating categories first.
Future<void> _seedDefaultTrainingTypes() async {
  final now = DateTime.now();
  final defaults = [
    TrainingType(
      id: generateId(),
      name: 'Running',
      iconCodePoint: 0xe566, // Icons.directions_run
      color: 0xFF1E88E5,
      createdAt: now,
    ),
    TrainingType(
      id: generateId(),
      name: 'Swimming',
      iconCodePoint: 0xe4c6, // Icons.pool
      color: 0xFF00ACC1,
      createdAt: now,
    ),
    TrainingType(
      id: generateId(),
      name: 'Cycling',
      iconCodePoint: 0xe527, // Icons.pedal_bike
      color: 0xFF43A047,
      createdAt: now,
    ),
    TrainingType(
      id: generateId(),
      name: 'Strength',
      iconCodePoint: 0xe8e1, // Icons.fitness_center
      color: 0xFF8E24AA,
      createdAt: now,
    ),
    TrainingType(
      id: generateId(),
      name: 'Yoga',
      iconCodePoint: 0xe5f3, // Icons.self_improvement
      color: 0xFF00897B,
      createdAt: now,
    ),
    TrainingType(
      id: generateId(),
      name: 'HIIT',
      iconCodePoint: 0xe7cb, // Icons.local_fire_department
      color: 0xFFFF6F00,
      createdAt: now,
    ),
    TrainingType(
      id: generateId(),
      name: 'Walking',
      iconCodePoint: 0xe536, // Icons.directions_walk
      color: 0xFF7CB342,
      createdAt: now,
    ),
  ];

  for (final type in defaults) {
    await trainingTypeStore.add(type);
  }
}
