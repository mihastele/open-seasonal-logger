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

    // Open through Drift; the first query runs onUpgrade to v2.
    final db = AppDatabase.forTesting(NativeDatabase(file));
    addTearDown(db.close);

    final seasons = await db.select(db.seasons).get();
    expect(seasons, hasLength(1));
    expect(seasons.single.title, 'Build a Tiny PLC');

    // The reminder settings table was created and seeded by the migration.
    final reminder = await db.select(db.reminderSettings).getSingle();
    expect(reminder.enabled, isTrue);
    expect(reminder.daysBeforeEnd, 5);

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
}
