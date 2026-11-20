import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../models/reminder_model.dart';
import 'reminder_service.dart';

/// Reminders as the phone's local notifications (iOS and Android). Times
/// are planned as exact moments (UTC), so no time-zone name is needed.
class DeviceReminderService implements ReminderService {
  DeviceReminderService([FlutterLocalNotificationsPlugin? plugin])
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _ready = false;
  bool _asked = false;

  static const _details = NotificationDetails(
    android: AndroidNotificationDetails(
      'payments',
      'Payments',
      channelDescription: 'Regular payments and debts coming due',
      importance: Importance.high,
      priority: Priority.high,
    ),
    iOS: DarwinNotificationDetails(),
  );

  Future<bool> _init() async {
    if (_ready) return true;
    try {
      tzdata.initializeTimeZones();
      await _plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          iOS: DarwinInitializationSettings(
            requestAlertPermission: false,
            requestSoundPermission: false,
            requestBadgePermission: false,
          ),
        ),
      );
      _ready = true;
    } on Object {
      _ready = false;
    }
    return _ready;
  }

  Future<void> _askOnce() async {
    if (_asked) return;
    _asked = true;
    await _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, sound: true, badge: true);
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  @override
  Future<void> replaceAll(List<ReminderModel> reminders) async {
    if (!await _init()) return;
    try {
      await _plugin.cancelAll();
      final now = DateTime.now();
      final future = [
        for (final r in reminders)
          if (r.when.isAfter(now)) r,
      ];
      if (future.isEmpty) return;
      await _askOnce();
      for (final r in future) {
        await _plugin.zonedSchedule(
          id: r.id,
          title: r.title,
          body: r.body,
          scheduledDate: tz.TZDateTime.from(r.when.toUtc(), tz.UTC),
          notificationDetails: _details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
      }
    } on Object {
      // Reminders are a help, never a reason for the app to fail.
    }
  }
}
