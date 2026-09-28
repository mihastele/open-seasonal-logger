import 'package:flutter_test/flutter_test.dart';
import 'package:seasonal/domain/season_math.dart';

void main() {
  final start = DateTime(2026, 9, 28);

  test('end date is start plus duration in weeks', () {
    expect(SeasonMath.endDate(start, 8), DateTime(2026, 11, 23));
  });

  test('current week is 1-based and clamped to the duration', () {
    expect(SeasonMath.currentWeek(start, 8, start), 1);
    expect(SeasonMath.currentWeek(start, 8, DateTime(2026, 10, 18)), 3);
    expect(SeasonMath.currentWeek(start, 8, DateTime(2026, 12, 31)), 8);
    expect(SeasonMath.currentWeek(start, 8, DateTime(2026, 9, 1)), 1);
  });

  test('progress is clamped to 0..1', () {
    expect(SeasonMath.progress(start, 8, DateTime(2026, 9, 1)), 0.0);
    expect(SeasonMath.progress(start, 8, DateTime(2027, 1, 1)), 1.0);
    final mid = SeasonMath.progress(start, 8, DateTime(2026, 10, 26));
    expect(mid, closeTo(0.5, 0.02));
  });

  test('days remaining never goes negative', () {
    expect(SeasonMath.daysRemaining(start, 8, DateTime(2027, 1, 1)), 0);
  });
}
