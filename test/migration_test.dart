import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seasonal/data/app_database.dart';
import 'package:sqlite3/sqlite3.dart';

/// Verifies the v1 -> v2 migration applies cleanly and preserves existing
/// seasons, as required by the engineering rules in AGENTS.md.
void main() {
  late Directory dir;
  late File file;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('seasonal_migration');
    file = File('${dir.path}/seasonal.sqlite');
  });

  tearDown(() {
    if (dir.existsSync()) dir.deleteSync(recursive: true);
  });

  test('v1 database upgrades to v2 and keeps its seasons', () async {
    // Build a v1 database by hand: seasons table only, user_version = 1.
    final raw = sqlite3.open(file.path);
    raw.execute('''
      CREATE TABLE seasons (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        start_date INTEGER NOT NULL,
        duration_weeks INTEGER NOT NULL,
        status TEXT NOT NULL,
        reflection_made TEXT,
        reflection_learned TEXT,
        reflection_return_someday TEXT,
        created_at INTEGER NOT NULL DEFAULT (strftime('%s', CURRENT_TIMESTAMP))
      );
    ''');
    raw.execute(
      "CREATE UNIQUE INDEX seasons_single_active "
      "ON seasons((1)) WHERE status = 'active'",
    );
    raw.execute('CREATE INDEX seasons_status ON seasons(status)');
    raw.execute(
      "INSERT INTO seasons (title, start_date, duration_weeks, status) "
      "VALUES ('Build a Tiny PLC', 0, 8, 'active')",
    );
    raw.execute('PRAGMA user_version = 1');
    raw.close();

    // Open through Drift; the first query runs onUpgrade to the latest schema.
    final db = AppDatabase.forTesting(NativeDatabase(file));
    addTearDown(db.close);

    final seasons = await db.select(db.seasons).get();
    expect(seasons, hasLength(1));
    expect(seasons.single.title, 'Build a Tiny PLC');

    // The reminder settings table was created and seeded by the migration.
    final reminder = await db.select(db.reminderSettings).getSingle();
    expect(reminder.enabled, isTrue);
    expect(reminder.daysBeforeEnd, 5);

    // The support settings table was created and seeded, on by default.
    final support = await db.select(db.supportSettings).getSingle();
    expect(support.showFooter, isTrue);

    // The single-active invariant survives the upgrade.
    expect(
      () => db.into(db.seasons).insert(
            SeasonsCompanion.insert(
              title: 'Second active',
              startDate: DateTime(2026, 9, 29),
              durationWeeks: 4,
              status: SeasonStatus.active,
            ),
          ),
      throwsA(anything),
    );
  });

  test('v3 database upgrades to v4 and shows the coffee link by default',
      () async {
    // Build a v3 database by hand: seasons, reminder_settings, and
    // support_settings with the old hidden-by-default seed.
    final raw = sqlite3.open(file.path);
    raw.execute('''
      CREATE TABLE seasons (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        start_date INTEGER NOT NULL,
        duration_weeks INTEGER NOT NULL,
        status TEXT NOT NULL,
        reflection_made TEXT,
        reflection_learned TEXT,
        reflection_return_someday TEXT,
        created_at INTEGER NOT NULL DEFAULT (strftime('%s', CURRENT_TIMESTAMP))
      );
    ''');
    raw.execute(
      "CREATE UNIQUE INDEX seasons_single_active "
      "ON seasons((1)) WHERE status = 'active'",
    );
    raw.execute('CREATE INDEX seasons_status ON seasons(status)');
    raw.execute(
      "INSERT INTO seasons (title, start_date, duration_weeks, status) "
      "VALUES ('Build a Tiny PLC', 0, 8, 'active')",
    );
    raw.execute('''
      CREATE TABLE reminder_settings (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        enabled INTEGER NOT NULL DEFAULT 1 CHECK (enabled IN (0, 1)),
        days_before_end INTEGER NOT NULL DEFAULT 5,
        time_of_day_minutes INTEGER NOT NULL DEFAULT 540
      );
    ''');
    raw.execute(
      'INSERT INTO reminder_settings (enabled, days_before_end, '
      'time_of_day_minutes) VALUES (1, 5, 540)',
    );
    raw.execute('''
      CREATE TABLE support_settings (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        show_footer INTEGER NOT NULL DEFAULT 0 CHECK (show_footer IN (0, 1))
      );
    ''');
    raw.execute('INSERT INTO support_settings (show_footer) VALUES (0)');
    raw.execute('PRAGMA user_version = 3');
    raw.close();

    final db = AppDatabase.forTesting(NativeDatabase(file));
    addTearDown(db.close);

    // Seasons are preserved.
    final seasons = await db.select(db.seasons).get();
    expect(seasons, hasLength(1));
    expect(seasons.single.title, 'Build a Tiny PLC');

    // The existing still-default row moves to the new on-by-default value.
    final support = await db.select(db.supportSettings).getSingle();
    expect(support.showFooter, isTrue);

    // The reminder preference is untouched.
    final reminder = await db.select(db.reminderSettings).getSingle();
    expect(reminder.enabled, isTrue);
    expect(reminder.daysBeforeEnd, 5);
  });
}
