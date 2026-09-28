import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:seasonal/domain/season_math.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Schedules the single, gentle end-of-season reminder.
///
/// Principle 3: no guilt-inducing notifications. Principle 5: nothing here
/// touches the network — all scheduling is local.
class SeasonNotificationService {
  /// How many days before a season ends the reminder fires.
  static const int remindDaysBeforeEnd = 5;

  static const int _reminderId = 1001;

  final FlutterLocalNotificationsPlugin _plugin;

  SeasonNotificationService({FlutterLocalNotificationsPlugin? plugin})
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized || kIsWeb) return;
    _initialized = true;
    try {
      tzdata.initializeTimeZones();
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (_) {
      // Fall back to UTC if the platform cannot report a zone. Scheduling
      // still works; the reminder may drift by the offset.
    }
    try {
      await _plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          iOS: DarwinInitializationSettings(),
        ),
      );
      await _requestPermission();
    } catch (_) {
      // Notifications are unavailable (e.g. headless tests or an
      // unsupported platform). The app works without them.
    }
  }

  Future<void> _requestPermission() async {
    if (Platform.isAndroid) {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await android?.requestNotificationsPermission();
    } else if (Platform.isIOS) {
      final ios = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      await ios?.requestPermissions(alert: true, sound: true, badge: false);
    }
  }

  /// (Re)schedules the reminder for a season. Replaces any previous reminder,
  /// so a season never accumulates more than one notification.
  ///
  /// [daysBeforeEnd] and [timeOfDayMinutes] come from the user's reminder
  /// settings. The reminder is skipped if it is disabled or would already be
  /// in the past.
  Future<void> scheduleEndOfSeasonReminder({
    required DateTime startDate,
    required int durationWeeks,
    bool enabled = true,
    int daysBeforeEnd = remindDaysBeforeEnd,
    int timeOfDayMinutes = 9 * 60,
    DateTime? now,
  }) async {
    if (kIsWeb) return;
    await init();
    await cancelReminder();
    if (!enabled) return;

    final end = SeasonMath.endDate(startDate, durationWeeks);
    final hour = timeOfDayMinutes ~/ 60;
    final minute = timeOfDayMinutes % 60;
    final fireOn = DateTime(end.year, end.month, end.day, hour, minute)
        .subtract(Duration(days: daysBeforeEnd));
    final reference = now ?? DateTime.now();
    if (!fireOn.isAfter(reference)) return;

    await _plugin.zonedSchedule(
      id: _reminderId,
      title: 'Your season is ending soon',
      body: 'What would you like to explore next?',
      scheduledDate: tz.TZDateTime.from(fireOn, tz.local),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'seasonal_end_of_season',
          'Season endings',
          channelDescription: 'A gentle reminder as a season draws to a close.',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  Future<void> cancelReminder() async {
    if (Platform.isAndroid || Platform.isIOS) {
      await _plugin.cancel(id: _reminderId);
    }
  }
}
