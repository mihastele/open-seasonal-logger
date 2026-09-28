import 'package:seasonal/data/app_database.dart';

/// Pure date math for a season. Kept free of Flutter and Drift runtime so it
/// can be tested directly.
class SeasonMath {
  static const int daysPerWeek = 7;

  /// The date a season ends (exclusive), i.e. [startDate] plus
  /// [durationWeeks] weeks.
  static DateTime endDate(DateTime startDate, int durationWeeks) {
    final start = _dateOnly(startDate);
    // Calendar arithmetic, not a fixed Duration, so a DST transition inside
    // the season cannot shift the end date by an hour.
    return DateTime(
      start.year,
      start.month,
      start.day + daysPerWeek * durationWeeks,
    );
  }

  /// How many days remain until the season ends on [now]. Zero if it has
  /// already ended.
  static int daysRemaining(DateTime startDate, int durationWeeks, DateTime now) {
    final end = endDate(startDate, durationWeeks);
    final remaining = end.difference(_dateOnly(now)).inDays;
    return remaining < 0 ? 0 : remaining;
  }

  /// Which week of the season [now] falls in, 1-based. Clamped to
  /// `[1, durationWeeks]` so it is always displayable.
  static int currentWeek(DateTime startDate, int durationWeeks, DateTime now) {
    final start = _dateOnly(startDate);
    final elapsed = _dateOnly(now).difference(start).inDays;
    if (elapsed < 0) return 1;
    final week = (elapsed ~/ daysPerWeek) + 1;
    if (week > durationWeeks) return durationWeeks;
    return week;
  }

  /// Fraction of the season elapsed, clamped to `0.0..1.0`.
  static double progress(DateTime startDate, int durationWeeks, DateTime now) {
    final start = _dateOnly(startDate);
    final end = endDate(startDate, durationWeeks);
    final total = end.difference(start).inDays;
    if (total <= 0) return 1.0;
    final elapsed = _dateOnly(now).difference(start).inDays;
    if (elapsed <= 0) return 0.0;
    if (elapsed >= total) return 1.0;
    return elapsed / total;
  }

  /// Whether the season has reached its end date as of [now].
  static bool isOver(DateTime startDate, int durationWeeks, DateTime now) {
    return !_dateOnly(now).isBefore(endDate(startDate, durationWeeks));
  }

  static DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);
}

extension SeasonDisplay on Season {
  DateTime get endsOn => SeasonMath.endDate(startDate, durationWeeks);

  int weeksLeft(DateTime now) =>
      SeasonMath.currentWeek(startDate, durationWeeks, now);

  double progressAt(DateTime now) =>
      SeasonMath.progress(startDate, durationWeeks, now);
}
