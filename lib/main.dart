import 'package:flutter/material.dart';
import 'package:seasonal/data/app_database.dart';
import 'package:seasonal/data/reminder_repository.dart';
import 'package:seasonal/data/season_repository.dart';
import 'package:seasonal/data/support_repository.dart';
import 'package:seasonal/services/season_notifications.dart';
import 'package:seasonal/ui/home_screen.dart';
import 'package:seasonal/ui/theme.dart';

void main() {
  runApp(const SeasonalApp());
}

/// Wires the app's dependencies. Kept tiny and explicit — v0.1 has no DI
/// framework and no backend.
class AppDependencies {
  AppDependencies({AppDatabase? database})
      : database = database ?? AppDatabase() {
    seasons = SeasonRepository(this.database);
    reminders = ReminderRepository(this.database);
    support = SupportRepository(this.database);
  }

  final AppDatabase database;
  late final SeasonRepository seasons;
  late final ReminderRepository reminders;
  late final SupportRepository support;
  final notifications = SeasonNotificationService();

  /// Re-schedules the end-of-season reminder from the saved settings and the
  /// current active season. Call after anything that changes either.
  Future<void> rescheduleReminder() async {
    final active = await seasons.activeSeason();
    final setting = await reminders.get();
    if (active == null) {
      await notifications.cancelReminder();
      return;
    }
    await notifications.scheduleEndOfSeasonReminder(
      startDate: active.startDate,
      durationWeeks: active.durationWeeks,
      enabled: setting.enabled,
      daysBeforeEnd: setting.daysBeforeEnd,
      timeOfDayMinutes: setting.timeOfDayMinutes,
    );
  }

  bool _disposed = false;

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    await database.close();
  }
}

class SeasonalApp extends StatefulWidget {
  const SeasonalApp({super.key, this.dependencies});

  final AppDependencies? dependencies;

  @override
  State<SeasonalApp> createState() => _SeasonalAppState();
}

class _SeasonalAppState extends State<SeasonalApp> {
  late final AppDependencies _deps = widget.dependencies ?? AppDependencies();

  @override
  void initState() {
    super.initState();
    _deps.notifications.init();
  }

  @override
  void dispose() {
    _deps.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Seasonal',
      debugShowCheckedModeBanner: false,
      theme: buildSeasonalTheme(),
      home: HomeScreen(dependencies: _deps),
    );
  }
}
