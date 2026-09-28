import 'package:flutter_test/flutter_test.dart';
import 'package:seasonal/data/reminder_repository.dart';

import 'test_database.dart';

void main() {
  test('principle 5 + 3: reminder settings are seeded with a season-end default',
      () async {
    final db = newTestDatabase();
    addTearDown(db.close);
    final repo = ReminderRepository(db);

    final setting = await repo.get();
    expect(setting.enabled, isTrue);
    expect(setting.daysBeforeEnd, 5);
    expect(setting.timeOfDayMinutes, 9 * 60);
  });

  test('reminder settings can be saved and read back', () async {
    final db = newTestDatabase();
    addTearDown(db.close);
    final repo = ReminderRepository(db);

    await repo.save(enabled: true, daysBeforeEnd: 1, timeOfDayMinutes: 20 * 60);

    final setting = await repo.get();
    expect(setting.daysBeforeEnd, 1);
    expect(setting.timeOfDayMinutes, 1200);
  });

  test('principle 3: the reminder table holds no streak or cadence fields',
      () async {
    final db = newTestDatabase();
    addTearDown(db.close);

    final columns =
        db.reminderSettings.$columns.map((c) => c.name.toLowerCase()).toList();
    const forbidden = [
      'streak',
      'cadence',
      'repeat',
      'interval',
      'frequency',
      'daily',
      'weekly',
    ];
    for (final name in columns) {
      for (final word in forbidden) {
        expect(name.contains(word), isFalse, reason: 'Column "$name"');
      }
    }
  });
}
