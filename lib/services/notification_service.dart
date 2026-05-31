import 'dart:ui' show Color;
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/medicine.dart';
import '../constants/app_strings.dart';

// Top-level so it runs in the background isolate when app is killed
@pragma('vm:entry-point')
void onBackgroundNotification(NotificationResponse response) {
  _speakReminder(response.payload);
}

Future<void> _speakReminder(String? payload) async {
  try {
    final tts = FlutterTts();
    await tts.setLanguage('en-IN');
    await tts.setSpeechRate(0.45);
    await tts.setPitch(1.0);
    final name = (payload != null && payload.isNotEmpty) ? payload : 'medicine';
    await tts.speak('Time to take your $name. Please take your medicine now.');
  } catch (e) {
    debugPrint('TTS error: $e');
  }
}

class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;

    tz.initializeTimeZones();
    final String localTz = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(localTz));

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
      onDidReceiveNotificationResponse: (response) {
        // Fires when notification tapped (foreground or background)
        _speakReminder(response.payload);
      },
      onDidReceiveBackgroundNotificationResponse: onBackgroundNotification,
    );

    _initialized = true;
  }

  static Future<bool> requestPermission() async {
    final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      final bool? notifGranted =
          await androidPlugin.requestNotificationsPermission();
      final bool? exactGranted =
          await androidPlugin.requestExactAlarmsPermission();
      return (notifGranted ?? false) && (exactGranted ?? true);
    }
    return true;
  }

  static Future<void> scheduleMedicineReminder(Medicine medicine) async {
    if (!_initialized) await init();

    await cancelMedicineReminder(medicine.id);

    final timeComponents = medicine.timeComponents;
    final int hour = timeComponents['hour']!;
    final int minute = timeComponents['minute']!;

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
          '${medicine.name} — ${medicine.dosage}',
          scheduledTime,
          _notificationDetails(medicine),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: medicine.frequency == 'weekly'
              ? DateTimeComponents.dayOfWeekAndTime
              : DateTimeComponents.time,
          payload: medicine.name, // passed to TTS
        );
        debugPrint('Scheduled: ${medicine.name} at $scheduledTime');
      } catch (e) {
        debugPrint('NotificationService: failed to schedule: $e');
      }
    }
  }

  static Future<void> cancelMedicineReminder(String medicineId) async {
    for (int i = 0; i < 3; i++) {
      await _plugin.cancel(_idFromString('${medicineId}_$i'));
    }
  }

  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  // ─────────────────────────────────────────────────────────────────────────

  static NotificationDetails _notificationDetails(Medicine medicine) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        AppStrings.channelId,
        AppStrings.channelName,
        channelDescription: AppStrings.channelDesc,
        importance: Importance.max,
        priority: Priority.max,
        icon: '@mipmap/ic_launcher',
        color: const Color(0xFF1565C0),
        playSound: true,
        enableVibration: true,
        fullScreenIntent: true,
        styleInformation: BigTextStyleInformation(
          'Time to take your ${medicine.name} — ${medicine.dosage}',
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
}
