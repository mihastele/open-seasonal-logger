import 'package:drift/drift.dart';
import 'package:seasonal/data/app_database.dart';

/// Reads and writes the user's single reminder preference.
///
/// The reminder is tied to the end of a season, not to a recurring habit
/// schedule. See `brand/BRAND.md` and the product principles.
class ReminderRepository {
  final AppDatabase db;
  ReminderRepository(this.db);

  Stream<ReminderSetting> watch() {
    return (db.select(db.reminderSettings)..limit(1)).watchSingle();
  }

  Future<ReminderSetting> get() {
    return (db.select(db.reminderSettings)..limit(1)).getSingle();
  }

  Future<void> save({
    required bool enabled,
    required int daysBeforeEnd,
    required int timeOfDayMinutes,
  }) {
    return (db.update(db.reminderSettings)).write(
      ReminderSettingsCompanion(
        enabled: Value(enabled),
        daysBeforeEnd: Value(daysBeforeEnd),
        timeOfDayMinutes: Value(timeOfDayMinutes),
      ),
    );
  }
}
