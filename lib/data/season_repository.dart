import 'package:drift/drift.dart';
import 'package:seasonal/data/app_database.dart';

/// Thrown when an operation would produce two `active` seasons. Principle 2
/// says a season is never ended or overwritten silently, and there is never
/// more than one active season.
class ActiveSeasonConflict implements Exception {
  @override
  String toString() =>
      'A season is already active. Finish it before starting another.';
}

/// Thrown when trying to start a season that is not upcoming.
class InvalidSeasonTransition implements Exception {
  final String message;
  InvalidSeasonTransition(this.message);
  @override
  String toString() => message;
}

/// Reads and writes seasons while preserving the season lifecycle:
/// at most one active season, and creating the next season never mutates the
/// current one.
class SeasonRepository {
  final AppDatabase db;
  SeasonRepository(this.db);

  Future<Season?> activeSeason() {
    return (db.select(db.seasons)
          ..where((t) => t.status.equals(SeasonStatus.active.name))
          ..limit(1))
        .getSingleOrNull();
  }

  Stream<Season?> watchActiveSeason() {
    return (db.select(db.seasons)
          ..where((t) => t.status.equals(SeasonStatus.active.name))
          ..limit(1))
        .watchSingleOrNull();
  }

  /// The soonest upcoming season, if any.
  Stream<Season?> watchUpcomingSeason() {
    return (db.select(db.seasons)
          ..where((t) => t.status.equals(SeasonStatus.upcoming.name))
          ..orderBy([(t) => OrderingTerm.asc(t.startDate)])
          ..limit(1))
        .watchSingleOrNull();
  }

  /// One-shot read of the soonest upcoming season.
  Future<Season?> upcomingSeason() {
    return (db.select(db.seasons)
          ..where((t) => t.status.equals(SeasonStatus.upcoming.name))
          ..orderBy([(t) => OrderingTerm.asc(t.startDate)])
          ..limit(1))
        .getSingleOrNull();
  }

  /// Seasons that are over: either explicitly completed or past their end
  /// date. Most recent first.
  Stream<List<Season>> watchPastSeasons() {
    return (db.select(db.seasons)
          ..where((t) => t.status.equals(SeasonStatus.completed.name))
          ..orderBy([(t) => OrderingTerm.desc(t.startDate)]))
        .watch();
  }

  Stream<List<Season>> watchAll() {
    return (db.select(db.seasons)
          ..orderBy([(t) => OrderingTerm.desc(t.startDate)]))
        .watch();
  }

  /// Creates a season.
  ///
  /// Creating an [upcoming] season is always allowed and never touches the
  /// current one. Creating an [active] season is refused while another season
  /// is active.
  Future<int> createSeason({
    required String title,
    String? description,
    required DateTime startDate,
    required int durationWeeks,
    required SeasonStatus status,
  }) {
    assert(durationWeeks > 0, 'durationWeeks must be positive');
    return db.transaction(() async {
      if (status == SeasonStatus.active) {
        final existing = await activeSeason();
        if (existing != null) throw ActiveSeasonConflict();
      }
      return db.into(db.seasons).insert(
            SeasonsCompanion.insert(
              title: title,
              description: Value(description),
              startDate: startDate,
              durationWeeks: durationWeeks,
              status: status,
            ),
          );
    });
  }

  /// Saves the three end-of-season prompts. All are optional.
  Future<void> saveReflection({
    required int seasonId,
    String? made,
    String? learned,
    String? returnSomeday,
  }) {
    return (db.update(db.seasons)..where((t) => t.id.equals(seasonId))).write(
      SeasonsCompanion(
        reflectionMade: Value(_blankToNull(made)),
        reflectionLearned: Value(_blankToNull(learned)),
        reflectionReturnSomeday: Value(_blankToNull(returnSomeday)),
      ),
    );
  }

  /// Ends a season. This is the only operation that changes `active` to
  /// `completed`; it never deletes the row or its reflection.
  Future<void> completeSeason(int seasonId) {
    return (db.update(db.seasons)..where((t) => t.id.equals(seasonId))).write(
      const SeasonsCompanion(status: Value(SeasonStatus.completed)),
    );
  }

  /// Starts an upcoming season, making it active. Refused if another season
  /// is already active (principle 2).
  Future<void> startUpcoming(int seasonId) {
    return db.transaction(() async {
      final season =
          await (db.select(db.seasons)..where((t) => t.id.equals(seasonId)))
              .getSingle();
      if (season.status != SeasonStatus.upcoming) {
        throw InvalidSeasonTransition('Season is not upcoming.');
      }
      final existing = await activeSeason();
      if (existing != null && existing.id != seasonId) {
        throw ActiveSeasonConflict();
      }
      await (db.update(db.seasons)..where((t) => t.id.equals(seasonId)))
          .write(const SeasonsCompanion(status: Value(SeasonStatus.active)));
    });
  }

  static String? _blankToNull(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
