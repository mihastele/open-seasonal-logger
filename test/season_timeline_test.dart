import 'package:flutter_test/flutter_test.dart';
import 'package:seasonal/data/app_database.dart';
import 'package:seasonal/domain/season_timeline.dart';

Season _season({
  int id = 1,
  String title = 'S',
  required DateTime start,
  int weeks = 8,
  required SeasonStatus status,
}) {
  return Season(
    id: id,
    title: title,
    description: null,
    startDate: start,
    durationWeeks: weeks,
    status: status,
    reflectionMade: null,
    reflectionLearned: null,
    reflectionReturnSomeday: null,
    createdAt: DateTime(2026, 1, 1),
  );
}

void main() {
  final now = DateTime(2026, 9, 28);

  test('empty timeline: next slot is active and starts today', () {
    const timeline = SeasonTimeline([]);
    final slot = timeline.nextSlot(now)!;
    expect(slot.becomesActive, isTrue);
    expect(slot.startDate, DateTime(2026, 9, 28));
    expect(timeline.isFull, isFalse);
  });

  test('active only: fills the first upcoming slot at its end date', () {
    final timeline = SeasonTimeline([
      _season(
        start: DateTime(2026, 9, 28),
        weeks: 8,
        status: SeasonStatus.active,
      ),
    ]);
    final slot = timeline.nextSlot(now)!;
    expect(slot.becomesActive, isFalse);
    expect(slot.isFirstUpcoming, isTrue);
    expect(slot.startDate, DateTime(2026, 11, 23));
    expect(slot.durationWeeks, 8);
  });

  test('active + 1 upcoming: appends the second upcoming after it', () {
    final timeline = SeasonTimeline([
      _season(
        start: DateTime(2026, 9, 28),
        weeks: 8,
        status: SeasonStatus.active,
      ),
      _season(
        id: 2,
        start: DateTime(2026, 11, 23),
        weeks: 8,
        status: SeasonStatus.upcoming,
      ),
    ]);
    final slot = timeline.nextSlot(now)!;
    expect(slot.startDate, DateTime(2027, 1, 18));
    expect(timeline.isFull, isFalse);
  });

  test('active + 2 upcoming is full and offers no slot', () {
    final timeline = SeasonTimeline([
      _season(
        start: DateTime(2026, 9, 28),
        weeks: 8,
        status: SeasonStatus.active,
      ),
      _season(
        id: 2,
        start: DateTime(2026, 11, 23),
        weeks: 8,
        status: SeasonStatus.upcoming,
      ),
      _season(
        id: 3,
        start: DateTime(2027, 1, 18),
        weeks: 8,
        status: SeasonStatus.upcoming,
      ),
    ]);
    expect(timeline.isFull, isTrue);
    expect(timeline.nextSlot(now), isNull);
  });

  test('gap after active (first upcoming deleted): refills in place', () {
    final timeline = SeasonTimeline([
      _season(
        start: DateTime(2026, 9, 28),
        weeks: 8,
        status: SeasonStatus.active,
      ),
      // The first upcoming was deleted; the chain now jumps past it.
      _season(
        id: 3,
        start: DateTime(2027, 1, 18),
        weeks: 8,
        status: SeasonStatus.upcoming,
      ),
    ]);
    final slot = timeline.nextSlot(now)!;
    // Starts exactly when the active season ends, not after the last season.
    expect(slot.startDate, DateTime(2026, 11, 23));
  });

  test('two upcoming present is full even if their dates are spaced out', () {
    final timeline = SeasonTimeline([
      _season(
        start: DateTime(2026, 9, 28),
        weeks: 8,
        status: SeasonStatus.active,
      ),
      _season(
        id: 2,
        start: DateTime(2026, 11, 23),
        weeks: 8,
        status: SeasonStatus.upcoming,
      ),
      // Second upcoming is far in the future. Still two present, so full.
      _season(
        id: 3,
        start: DateTime(2027, 6, 1),
        weeks: 8,
        status: SeasonStatus.upcoming,
      ),
    ]);
    expect(timeline.isFull, isTrue);
    expect(timeline.nextSlot(now), isNull);
  });

  test('no active season but upcoming exist: new season becomes active today',
      () {
    final timeline = SeasonTimeline([
      _season(
        start: DateTime(2026, 11, 23),
        weeks: 8,
        status: SeasonStatus.upcoming,
      ),
    ]);
    final slot = timeline.nextSlot(now)!;
    expect(slot.becomesActive, isTrue);
    expect(slot.startDate, DateTime(2026, 9, 28));
    expect(timeline.isFull, isFalse);
  });
}
