import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:seasonal/data/app_database.dart';

/// A fresh in-memory database for tests.
///
/// Uses `closeStreamsSynchronously: true` so cancelling a query stream does not
/// leave a zero-duration timer behind, which would otherwise trip the widget
/// test "timer still pending" check.
AppDatabase newTestDatabase() {
  return AppDatabase.forTesting(
    DatabaseConnection(
      NativeDatabase.memory(),
      closeStreamsSynchronously: true,
    ),
  );
}
