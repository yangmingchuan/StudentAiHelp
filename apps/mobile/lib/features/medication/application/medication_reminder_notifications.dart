import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:little_hero/features/medication/domain/medication_models.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final medicationReminderNotificationsProvider =
    Provider<MedicationReminderNotifications>((ref) {
      return MedicationReminderNotifications(FlutterLocalNotificationsPlugin());
    });

/// Keeps medication details out of the operating-system notification preview.
/// The full reminder remains available only after opening the app.
class MedicationReminderNotifications {
  MedicationReminderNotifications(this._plugin);

  final FlutterLocalNotificationsPlugin _plugin;
  Future<void>? _initialization;

  Future<void> _ensureInitialized() {
    return _initialization ??= _initialize();
  }

  Future<void> _initialize() async {
    tz.initializeTimeZones();
    try {
      final deviceTimeZone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(deviceTimeZone.identifier));
    } catch (_) {
      // A valid timezone is still required by zonedSchedule on devices that
      // cannot report one (for example, some test devices).
      tz.setLocalLocation(tz.getLocation('Asia/Shanghai'));
    }

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('ic_notification'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
  }

  Future<bool> requestPermission() async {
    await _ensureInitialized();
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final granted = await android?.requestNotificationsPermission();
    if (granted != null) return granted;

    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    return await ios?.requestPermissions(
          alert: true,
          badge: false,
          sound: true,
        ) ??
        true;
  }

  Future<bool> schedule(MedicationReminder reminder) async {
    if (reminder.status != MedicationReminderStatus.scheduled ||
        !reminder.remindAt.isAfter(DateTime.now())) {
      return false;
    }
    if (!await requestPermission()) return false;
    await _plugin.zonedSchedule(
      id: reminder.id,
      title: '用药提醒',
      body: '打开应用查看提醒详情',
      scheduledDate: tz.TZDateTime.from(reminder.remindAt, tz.local),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'medication_reminders',
          '用药提醒',
          channelDescription: '提醒用户按计划处理用药事项',
          importance: Importance.max,
          priority: Priority.high,
          visibility: NotificationVisibility.private,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: false,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: 'medication-reminder:${reminder.id}',
    );
    return true;
  }

  Future<void> cancel(int reminderId) async {
    await _ensureInitialized();
    await _plugin.cancel(id: reminderId);
  }
}
