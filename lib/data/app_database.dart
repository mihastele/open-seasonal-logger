import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

/// The lifecycle states a season can be in.
///
/// Exactly one season may be [active] at a time. This is enforced in the
/// database by a partial unique index (see [AppDatabase]).
enum SeasonStatus { upcoming, active, completed }

/// A single thing the user is exploring this season.
///
/// Reflection is stored as exactly three optional fields, never a report:
/// what was made, what was learned, and whether they'd return someday.
@TableIndex(name: 'seasons_start_date', columns: {#startDate})
class Seasons extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get title => text().withLength(min: 1, max: 120)();

  TextColumn get description => text().nullable()();

  DateTimeColumn get startDate => dateTime()();

  IntColumn get durationWeeks => integer()();

  TextColumn get status => textEnum<SeasonStatus>()();

  // The end-of-season ritual: exactly three prompts, all optional.
  TextColumn get reflectionMade => text().nullable()();
  TextColumn get reflectionLearned => text().nullable()();
  TextColumn get reflectionReturnSomeday => text().nullable()();

  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}

/// A single-row table holding the user's one reminder preference.
///
/// This is one reminder tied to the end of a season — not a recurring habit
/// schedule. A season has a natural stopping point, and so does its reminder.
class ReminderSettings extends Table {
  IntColumn get id => integer().autoIncrement()();

  BoolColumn get enabled => boolean().withDefault(const Constant(true))();

  /// How many days before a season ends the reminder fires.
  IntColumn get daysBeforeEnd => integer().withDefault(const Constant(5))();

  /// Local time of day to fire, as minutes since midnight (default 09:00).
  IntColumn get timeOfDayMinutes =>
      integer().withDefault(const Constant(9 * 60))();
}


@DriftDatabase(tables: [Seasons, ReminderSettings])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await _createInvariantIndexes();
          await _seedReminderSettings();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(reminderSettings);
            await _seedReminderSettings();
          }
          // Recreate the invariant indexes; safe if they already exist.
          await _createInvariantIndexes();
        },
      );

  Future<void> _createInvariantIndexes() async {
    // At most one row may be active. This is a data-layer invariant, not a
    // UI-only convention: a partial unique index over a constant expression
    // rejects any second `active` row.
    await customStatement(
      "CREATE UNIQUE INDEX IF NOT EXISTS seasons_single_active "
      "ON seasons((1)) WHERE status = 'active'",
    );
    await customStatement(
      "CREATE INDEX IF NOT EXISTS seasons_status ON seasons(status)",
    );
  }

  Future<void> _seedReminderSettings() async {
    final count = await reminderSettings.count().getSingle();
    if (count == 0) {
      await into(reminderSettings).insert(
        ReminderSettingsCompanion.insert(),
      );
    }
  }

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'seasonal');
  }
}

extension SeasonStatusChecks on SeasonStatus {
  static SeasonStatus fromName(String value) {
    return SeasonStatus.values.firstWhere(
      (s) => s.name == value,
      orElse: () => SeasonStatus.upcoming,
    );
  }
}
