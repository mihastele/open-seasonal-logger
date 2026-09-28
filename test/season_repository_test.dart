import 'package:flutter_test/flutter_test.dart';
import 'package:seasonal/data/app_database.dart';
import 'package:seasonal/data/season_repository.dart';

import 'test_database.dart';

void main() {
  late AppDatabase db;
  late SeasonRepository repo;

  setUp(() {
    db = newTestDatabase();
    repo = SeasonRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  test(
    'principle 2: the data layer refuses a second active season',
    () async {
      await repo.createSeason(
        title: 'Build a Tiny PLC',
        startDate: DateTime(2026, 9, 28),
        durationWeeks: 8,
        status: SeasonStatus.active,
      );

      expect(
        () => repo.createSeason(
          title: 'Learn Swedish',
          startDate: DateTime(2026, 9, 29),
          durationWeeks: 8,
          status: SeasonStatus.active,
        ),
        throwsA(isA<ActiveSeasonConflict>()),
      );
      expect((await repo.watchAll().first).length, 1);
    },
  );

  test(
    'principle 2: the database rejects a raw second active insert',
    () async {
      await repo.createSeason(
        title: 'Build a Tiny PLC',
        startDate: DateTime(2026, 9, 28),
        durationWeeks: 8,
        status: SeasonStatus.active,
      );

      expect(
        () => db.into(db.seasons).insert(
              SeasonsCompanion.insert(
                title: 'Sneaky second active',
                startDate: DateTime(2026, 9, 29),
                durationWeeks: 4,
                status: SeasonStatus.active,
              ),
            ),
        throwsA(anything),
      );
    },
  );

  test(
    'principle 2: planning the next season never touches the current one',
    () async {
      final currentId = await repo.createSeason(
        title: 'Build a Tiny PLC',
        startDate: DateTime(2026, 9, 28),
        durationWeeks: 8,
        status: SeasonStatus.active,
      );

      await repo.createSeason(
        title: 'Learn Swedish',
        startDate: DateTime(2026, 11, 23),
        durationWeeks: 8,
        status: SeasonStatus.upcoming,
      );

      final current = await repo.activeSeason();
      expect(current!.id, currentId);
      expect(current.title, 'Build a Tiny PLC');
      expect(current.status, SeasonStatus.active);

      final upcoming = await repo.watchUpcomingSeason().first;
      expect(upcoming!.title, 'Learn Swedish');
    },
  );

  test('reflection keeps exactly three optional prompts', () async {
    final id = await repo.createSeason(
      title: 'Build a Tiny PLC',
      startDate: DateTime(2026, 9, 28),
      durationWeeks: 8,
      status: SeasonStatus.completed,
    );

    await repo.saveReflection(
      seasonId: id,
      made: '  A working PLC  ',
      learned: '   ',
      returnSomeday: 'Maybe a bigger one',
    );

    final season =
        await (db.select(db.seasons)..where((t) => t.id.equals(id)))
            .getSingle();
    expect(season.reflectionMade, 'A working PLC');
    expect(season.reflectionLearned, isNull);
    expect(season.reflectionReturnSomeday, 'Maybe a bigger one');
  });

  test('completing a season keeps the row and its reflection', () async {
    final id = await repo.createSeason(
      title: 'Build a Tiny PLC',
      startDate: DateTime(2026, 9, 28),
      durationWeeks: 8,
      status: SeasonStatus.active,
    );
    await repo.saveReflection(seasonId: id, learned: 'A little');
    await repo.completeSeason(id);

    final season =
        await (db.select(db.seasons)..where((t) => t.id.equals(id)))
            .getSingle();
    expect(season.status, SeasonStatus.completed);
    expect(season.reflectionLearned, 'A little');
  });
}
