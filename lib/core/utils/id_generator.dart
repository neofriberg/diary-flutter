import 'dart:math';

/// Generates a reasonably unique ID string without external dependencies.
String generateId() {
  final now = DateTime.now().millisecondsSinceEpoch;
  final rand = Random().nextInt(999999);
  return '${now}_$rand';
}
