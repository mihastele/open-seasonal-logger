import 'package:seasonal/data/app_database.dart';
import 'package:seasonal/domain/season_math.dart';

/// The most upcoming seasons a user may plan ahead. One active season plus
/// this many future seasons is "full"; the create action disappears until a
/// slot frees up.
const int maxUpcomingSeasons = 2;

/// Where a newly created season should begin, and a short reason for it, so
/// the UI can explain the suggested date.
class PlannedSlot {
  const PlannedSlot({
    required this.startDate,
    required this.durationWeeks,
    required this.reason,
  });

  final DateTime startDate;
  final int durationWeeks;

  /// One of: `active`, `upcoming-1`, `upcoming-2`.
  final String reason;

  bool get becomesActive => reason == 'active';

  bool get isFirstUpcoming => reason == 'upcoming-1';
}

/// Pure planning rules for the season timeline: which slot is missing, where
/// the next season goes, and whether the timeline is full.
///
/// Kept free of Flutter and Drift so it can be tested directly.
class SeasonTimeline {
  final List<Season> seasons;
  const SeasonTimeline(this.seasons);

  Season? get active {
    for (final s in seasons) {
      if (s.status == SeasonStatus.active) return s;
    }
    return null;
  }

  /// Upcoming seasons, soonest first.
  List<Season> get upcoming {
    final result = seasons
        .where((s) => s.status == SeasonStatus.upcoming)
        .toList()
      ..sort((a, b) => a.startDate.compareTo(b.startDate));
    return result;
  }

  /// Whether one active season and [maxUpcomingSeasons] upcoming seasons are
  /// all present.
  bool get isFull =>
      active != null && upcoming.length >= maxUpcomingSeasons;

  /// The next season to create, or null when the timeline is full.
  ///
  /// Placement follows the user's rule:
  /// - if no season is active, the new season is active and starts today;
  /// - otherwise, find the first gap in the active + upcoming chain and start
  ///   the new season exactly when the previous season ends (filling the gap);
  /// - if there is no gap, append after the last planned season.
  PlannedSlot? nextSlot(DateTime now) {
    if (isFull) return null;

    final current = active;
    if (current == null) {
      return PlannedSlot(
        startDate: _dateOnly(now),
        durationWeeks: 8,
        reason: 'active',
      );
    }

    final chain = <Season>[current, ...upcoming];
    for (var i = 0; i < chain.length && i < maxUpcomingSeasons; i++) {
      final previousEnd =
          SeasonMath.endDate(chain[i].startDate, chain[i].durationWeeks);
      final hasNext = i + 1 < chain.length;
      final nextStartsAtPreviousEnd = hasNext &&
          _isSameDate(chain[i + 1].startDate, previousEnd);
      if (!hasNext || !nextStartsAtPreviousEnd) {
        return PlannedSlot(
          startDate: previousEnd,
          durationWeeks: chain[i].durationWeeks,
          reason: i == 0 ? 'upcoming-1' : 'upcoming-2',
        );
      }
    }

    // No gap: append after the last planned season.
    final last = chain.last;
    return PlannedSlot(
      startDate: SeasonMath.endDate(last.startDate, last.durationWeeks),
      durationWeeks: last.durationWeeks,
      reason: chain.length >= 2 ? 'upcoming-2' : 'upcoming-1',
    );
  }

  static bool _isSameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);
}
