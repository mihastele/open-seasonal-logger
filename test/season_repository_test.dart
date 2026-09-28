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

  test('the data layer refuses a third upcoming season', () async {
    await repo.createSeason(
      title: 'Active',
      startDate: DateTime(2026, 9, 28),
      durationWeeks: 8,
      status: SeasonStatus.active,
    );
    await repo.createSeason(
      title: 'Next 1',
      startDate: DateTime(2026, 11, 23),
      durationWeeks: 8,
      status: SeasonStatus.upcoming,
    );
    await repo.createSeason(
      title: 'Next 2',
      startDate: DateTime(2027, 1, 18),
      durationWeeks: 8,
      status: SeasonStatus.upcoming,
    );

    expect(
      () => repo.createSeason(
        title: 'Next 3',
        startDate: DateTime(2027, 3, 15),
        durationWeeks: 8,
        status: SeasonStatus.upcoming,
      ),
      throwsA(isA<UpcomingSeasonLimit>()),
    );
    expect((await repo.upcomingSeasons()).length, 2);
  });

  test('deleting a season removes the row and its reflection', () async {
    final id = await repo.createSeason(
      title: 'Build a Tiny PLC',
      startDate: DateTime(2026, 9, 28),
      durationWeeks: 8,
      status: SeasonStatus.active,
    );
    await repo.saveReflection(seasonId: id, made: 'a thing');

    await repo.deleteSeason(id);

    expect(await repo.activeSeason(), isNull);
    expect(await repo.all(), isEmpty);
  });

  test('deleting the active season frees the active slot', () async {
    final activeId = await repo.createSeason(
      title: 'Active',
      startDate: DateTime(2026, 9, 28),
      durationWeeks: 8,
      status: SeasonStatus.active,
    );
    await repo.deleteSeason(activeId);

    await repo.createSeason(
      title: 'Replacement',
      startDate: DateTime(2026, 9, 28),
      durationWeeks: 8,
      status: SeasonStatus.active,
    );
    expect((await repo.activeSeason())!.title, 'Replacement');
  });

  test('updating a season changes its editable fields but not its status',
      () async {
    final id = await repo.createSeason(
      title: 'Build a Tiny PLC',
      startDate: DateTime(2026, 9, 28),
      durationWeeks: 8,
      status: SeasonStatus.active,
    );

    await repo.updateSeason(
      seasonId: id,
      title: 'Build a Bigger PLC',
      description: '  still embedded  ',
      startDate: DateTime(2026, 10, 5),
      durationWeeks: 12,
    );

    final season =
        await (db.select(db.seasons)..where((t) => t.id.equals(id)))
            .getSingle();
    expect(season.title, 'Build a Bigger PLC');
    expect(season.description, 'still embedded');
    expect(season.startDate, DateTime(2026, 10, 5));
    expect(season.durationWeeks, 12);
    expect(season.status, SeasonStatus.active);
  });
}
