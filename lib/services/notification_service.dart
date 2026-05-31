import 'dart:io' show Platform;
import 'dart:ui' show Color;
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/medicine.dart';
import '../constants/app_strings.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// NotificationService
/// Manages local notifications for medicine reminders using
/// flutter_local_notifications with timezone-aware scheduling.
/// ─────────────────────────────────────────────────────────────────────────────
class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  static bool get _supportsNotifications {
    if (kIsWeb) return false;
    return Platform.isAndroid || Platform.isIOS;
  }

  /// Initialize the notification plugin. Call once in main().
  static Future<void> init() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    if (!_supportsNotifications) {
      _initialized = true;
      return;
    }

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    _initialized = true;
  }

  /// Request notification permission (Android 13+).
  static Future<bool> requestPermission() async {
    if (!_supportsNotifications) return true;

    final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      final bool? granted =
          await androidPlugin.requestNotificationsPermission();
      return granted ?? false;
    }
    return true; // iOS handles this in init
  }

  /// Schedule daily notification for a medicine.
  static Future<void> scheduleMedicineReminder(Medicine medicine) async {
    if (!_supportsNotifications) return;
    if (!_initialized) await init();

    // Cancel any existing notification for this medicine
    await cancelMedicineReminder(medicine.id);

    final timeComponents = medicine.timeComponents;
    final int hour = timeComponents['hour']!;
    final int minute = timeComponents['minute']!;

    // Determine notification IDs and times based on frequency
    final List<int> notifIds =
        _getNotificationIds(medicine.id, medicine.frequency);
    final List<Map<String, int>> times =
        _getScheduleTimes(hour, minute, medicine.frequency);

    for (int i = 0; i < notifIds.length; i++) {
      final scheduledTime = _nextInstanceOfTime(
        times[i]['hour']!,
        times[i]['minute']!,
      );

      try {
        await _plugin.zonedSchedule(
          notifIds[i],
          AppStrings.notifTitle,
          '${AppStrings.notifBody}${medicine.name} (${medicine.dosage})',
          scheduledTime,
          _notificationDetails(medicine),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: medicine.frequency == 'weekly'
              ? DateTimeComponents.dayOfWeekAndTime
              : DateTimeComponents.time,
        );
      } catch (e) {
        debugPrint('NotificationService: failed to schedule: $e');
      }
    }
  }

  /// Cancel all notifications for a medicine.
  static Future<void> cancelMedicineReminder(String medicineId) async {
    if (!_supportsNotifications) return;
    for (int i = 0; i < 3; i++) {
      await _plugin.cancel(_idFromString('${medicineId}_$i'));
    }
  }

  /// Cancel all scheduled notifications.
  static Future<void> cancelAll() async {
    if (!_supportsNotifications) return;
    await _plugin.cancelAll();
  }

  // ───────────────────────────── Helpers ───────────────────────────────────

  static NotificationDetails _notificationDetails(Medicine medicine) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        AppStrings.channelId,
        AppStrings.channelName,
        channelDescription: AppStrings.channelDesc,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        color: const Color(0xFF1565C0),
        playSound: true,
        enableVibration: true,
        styleInformation: BigTextStyleInformation(
          '${AppStrings.notifBody}${medicine.name} — ${medicine.dosage}',
          summaryText: medicine.frequencyLabel,
        ),
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
  }

  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  static int _idFromString(String s) {
    return s.hashCode.abs() % 2147483647;
  }

  static List<int> _getNotificationIds(String medicineId, String frequency) {
    switch (frequency) {
      case 'twice_daily':
        return [
          _idFromString('${medicineId}_0'),
          _idFromString('${medicineId}_1'),
        ];
      case 'thrice_daily':
        return [
          _idFromString('${medicineId}_0'),
          _idFromString('${medicineId}_1'),
          _idFromString('${medicineId}_2'),
        ];
      default:
        return [_idFromString('${medicineId}_0')];
    }
  }

  static List<Map<String, int>> _getScheduleTimes(
      int hour, int minute, String frequency) {
    switch (frequency) {
      case 'twice_daily':
        return [
          {'hour': hour, 'minute': minute},
          {'hour': (hour + 12) % 24, 'minute': minute},
        ];
      case 'thrice_daily':
        return [
          {'hour': hour, 'minute': minute},
          {'hour': (hour + 8) % 24, 'minute': minute},
          {'hour': (hour + 16) % 24, 'minute': minute},
        ];
      default:
        return [
          {'hour': hour, 'minute': minute},
        ];
    }
  }

  static void _onNotificationTap(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
  }
}
