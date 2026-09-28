import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seasonal/data/app_database.dart';
import 'package:seasonal/main.dart';

import 'test_database.dart';

/// Builds the real app against an in-memory database.
AppDependencies testDependencies() {
  return AppDependencies(database: newTestDatabase());
}

/// Tears the widget tree down and closes the database.
///
/// The database is closed before the tree is removed: a live [StreamBuilder]
/// holding a Drift query can otherwise block teardown while the modal sheet is
/// still mounted. Test databases also use `closeStreamsSynchronously`, so no
/// timers are left pending.
Future<void> teardownApp(
  WidgetTester tester,
  AppDependencies deps,
) async {
  await deps.database.close();
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump();
}

void main() {
  testWidgets('home screen shows the current season and ends on time',
      (tester) async {
    final deps = testDependencies();

    await deps.seasons.createSeason(
      title: 'Build a Tiny PLC',
      description: 'Learn embedded control by actually building one.',
      startDate: DateTime.now().subtract(const Duration(days: 14)),
      durationWeeks: 8,
      status: SeasonStatus.active,
    );

    await tester.pumpWidget(SeasonalApp(dependencies: deps));
    await tester.pumpAndSettle();

    expect(find.text('SEASONAL'), findsOneWidget);
    expect(find.text('Build a Tiny PLC'), findsOneWidget);
    expect(find.text('Week 3 of 8'), findsOneWidget);
    expect(find.text('Open Season'), findsOneWidget);
    expect(find.text('No season planned yet.'), findsOneWidget);

    await teardownApp(tester, deps);
  });

  testWidgets(
      'planning a season while one is active creates an upcoming season '
      'and leaves the current one untouched', (tester) async {
    final deps = testDependencies();

    final currentId = await deps.seasons.createSeason(
      title: 'Build a Tiny PLC',
      startDate: DateTime.now(),
      durationWeeks: 8,
      status: SeasonStatus.active,
    );

    await tester.pumpWidget(SeasonalApp(dependencies: deps));
    await tester.pumpAndSettle();

    await tester.tap(find.text('New season'));
    await tester.pumpAndSettle();

    expect(find.text('What next?'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, 'Learn Swedish');
    await tester.tap(find.text('Save season'));
    await tester.pumpAndSettle();

    final active = await deps.seasons.activeSeason();
    expect(active!.id, currentId);
    expect(active.title, 'Build a Tiny PLC');

    final upcoming = await deps.seasons.upcomingSeason();
    expect(upcoming!.title, 'Learn Swedish');
    expect(upcoming.status, SeasonStatus.upcoming);

    await teardownApp(tester, deps);
  });

  testWidgets('the new-season sheet prompts differently with no active season',
      (tester) async {
    final deps = testDependencies();

    await tester.pumpWidget(SeasonalApp(dependencies: deps));
    await tester.pumpAndSettle();

    await tester.tap(find.text('New season'));
    await tester.pumpAndSettle();

    expect(find.text('What would you like to explore?'), findsOneWidget);

    await teardownApp(tester, deps);
  });

  testWidgets('the season screen offers exactly three reflection prompts',
      (tester) async {
    final deps = testDependencies();

    await deps.seasons.createSeason(
      title: 'Build a Tiny PLC',
      startDate: DateTime.now().subtract(const Duration(days: 60)),
      durationWeeks: 8,
      status: SeasonStatus.completed,
    );

    await tester.pumpWidget(SeasonalApp(dependencies: deps));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Build a Tiny PLC'));
    await tester.pumpAndSettle();

    expect(find.text('What did I make?'), findsOneWidget);
    expect(find.text('What did I learn?'), findsOneWidget);
    expect(find.text('Do I want to return to this someday?'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(3));
    expect(find.text('Save reflection'), findsOneWidget);

    await teardownApp(tester, deps);
  });

  testWidgets('swiping a season reveals Edit and Delete actions',
      (tester) async {
    final deps = testDependencies();
    await deps.seasons.createSeason(
      title: 'Build a Tiny PLC',
      startDate: DateTime.now(),
      durationWeeks: 8,
      status: SeasonStatus.active,
    );

    await tester.pumpWidget(SeasonalApp(dependencies: deps));
    await tester.pumpAndSettle();

    await tester.drag(find.text('Build a Tiny PLC'), const Offset(-260, 0));
    await tester.pumpAndSettle();

    expect(find.text('Edit'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);

    await teardownApp(tester, deps);
  });

  testWidgets('deleting via the swipe action removes the season',
      (tester) async {
    final deps = testDependencies();
    await deps.seasons.createSeason(
      title: 'Build a Tiny PLC',
      startDate: DateTime.now(),
      durationWeeks: 8,
      status: SeasonStatus.active,
    );

    await tester.pumpWidget(SeasonalApp(dependencies: deps));
    await tester.pumpAndSettle();

    await tester.drag(find.text('Build a Tiny PLC'), const Offset(-260, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    // Confirm the destructive dialog.
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(await deps.seasons.all(), isEmpty);
    expect(find.text('Build a Tiny PLC'), findsNothing);

    await teardownApp(tester, deps);
  });

  testWidgets('editing via the swipe action opens the sheet prefilled',
      (tester) async {
    final deps = testDependencies();
    await deps.seasons.createSeason(
      title: 'Build a Tiny PLC',
      startDate: DateTime.now(),
      durationWeeks: 8,
      status: SeasonStatus.active,
    );

    await tester.pumpWidget(SeasonalApp(dependencies: deps));
    await tester.pumpAndSettle();

    await tester.drag(find.text('Build a Tiny PLC'), const Offset(-260, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();

    expect(find.text('Edit season'), findsOneWidget);
    expect(find.text('Save changes'), findsOneWidget);
    expect(find.text('Build a Tiny PLC'), findsWidgets);

    await teardownApp(tester, deps);
  });

  testWidgets(
      'the new-season button disappears when one active and two upcoming exist',
      (tester) async {
    final deps = testDependencies();
    await deps.seasons.createSeason(
      title: 'Active',
      startDate: DateTime.now(),
      durationWeeks: 8,
      status: SeasonStatus.active,
    );
    await deps.seasons.createSeason(
      title: 'Next 1',
      startDate: DateTime.now().add(const Duration(days: 56)),
      durationWeeks: 8,
      status: SeasonStatus.upcoming,
    );
    await deps.seasons.createSeason(
      title: 'Next 2',
      startDate: DateTime.now().add(const Duration(days: 112)),
      durationWeeks: 8,
      status: SeasonStatus.upcoming,
    );

    await tester.pumpWidget(SeasonalApp(dependencies: deps));
    await tester.pumpAndSettle();

    expect(find.text('New season'), findsNothing);
    expect(find.text('UP NEXT (2/2)'), findsOneWidget);

    await teardownApp(tester, deps);
  });
}
