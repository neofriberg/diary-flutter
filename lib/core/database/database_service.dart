import 'package:hive_flutter/hive_flutter.dart';

/// Initializes and exposes Hive boxes for all app data.
///
/// Call [init] once in `main()` before any store is accessed.
class DatabaseService {
  static final DatabaseService instance = DatabaseService._();
  DatabaseService._();

  late final Box<String> sessionBox;
  late final Box<String> focusBox;
  late final Box<String> trainingTypeBox;
  late final Box<String> profileBox;

  /// Opens all Hive boxes. Must be awaited before `runApp`.
  Future<void> init() async {
    await Hive.initFlutter();
    sessionBox = await Hive.openBox<String>('sessions');
    focusBox = await Hive.openBox<String>('focusPoints');
    trainingTypeBox = await Hive.openBox<String>('trainingTypes');
    profileBox = await Hive.openBox<String>('userProfile');
  }
}
