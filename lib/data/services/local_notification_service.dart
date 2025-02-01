import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:restaurant_app/domain/entities/received_notification.dart';
import 'package:shared_preferences/shared_preferences.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

final StreamController<ReceivedNotification> didReceiveLocalNotificationStream =
    StreamController<ReceivedNotification>.broadcast();

final StreamController<String?> selectNotificationStream =
    StreamController<String?>.broadcast();

class LocalNotificationService {
  Future<void> init() async {
    const initializationSettingsAndroid = AndroidInitializationSettings(
      'app_icon',
    );
    final initializationSettingsDarwin = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    final initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (notificationResponse) {
        final payload = notificationResponse.payload;
        if (payload != null && payload.isNotEmpty) {
          selectNotificationStream.add(payload);
        }
      },
    );
  }

  Future<bool> isAndroidPermissionGranted() async {
    return await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.areNotificationsEnabled() ??
        false;
  }

  Future<bool> _requestAndroidNotificationsPermission() async {
    return await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.requestNotificationsPermission() ??
        false;
  }

  Future<bool?> requestPermissions() async {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final iOSImplementation =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
      return await iOSImplementation?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      final notificationEnabled = await isAndroidPermissionGranted();
      final requestAlarmEnabled = await _requestExactAlarmsPermission();
      if (!notificationEnabled) {
        final requestNotificationsPermission =
            await _requestAndroidNotificationsPermission();
        return requestNotificationsPermission && requestAlarmEnabled;
      }
      return notificationEnabled && requestAlarmEnabled;
    } else {
      return false;
    }
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    required String payload,
    String channelId = "1",
    String channelName = "Simple Notification",
  }) async {
    final androidPlatformChannelSpecifics = AndroidNotificationDetails(
      channelId,
      channelName,
      importance: Importance.max,
      priority: Priority.high,
      sound: const RawResourceAndroidNotificationSound('slow_spring_board'),
    );
    const iOSPlatformChannelSpecifics = DarwinNotificationDetails(
      sound: 'slow_spring_board.aiff',
      presentSound: true,
    );
    final notificationDetails = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );
    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  Future<void> showRestaurantNotification({
    required int id,
    required String title,
    required String body,
    required String payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'restaurant_notification',
      'Restaurant Notification',
      channelDescription: 'Notifications for restaurant recommendations',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      styleInformation: BigTextStyleInformation(''),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  Future<void> configureLocalTimeZone() async {
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));
  }

  tz.TZDateTime _nextInstanceOfTenAM() {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, 10, 0);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  Future<bool> _requestExactAlarmsPermission() async {
    return await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.requestExactAlarmsPermission() ??
        false;
  }

  Future<void> scheduleDailyTenAMNotification({
    required int id,
    String channelId = "3",
    String channelName = "Schedule Notification",
  }) async {
    final androidPlatformChannelSpecifics = AndroidNotificationDetails(
      channelId,
      channelName,
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );
    const iOSPlatformChannelSpecifics = DarwinNotificationDetails();

    final notificationDetails = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    final datetimeSchedule = _nextInstanceOfTenAM();

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      'Daily scheduled notification title',
      'This is a body of daily scheduled notification',
      datetimeSchedule,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.wallClockTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> scheduleDailyLunchReminder({required int id}) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      11, // 11 AM
      0,  // 0 minutes
    );

    // If it's past 11 AM, schedule for tomorrow
    if (now.isAfter(scheduledDate)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    debugPrint('Scheduling notification for: ${scheduledDate.toString()}');

    final androidDetails = AndroidNotificationDetails(
      'daily_lunch_reminder',
      'Daily Lunch Reminder',
      channelDescription: 'Daily restaurant recommendations for lunch',
      importance: Importance.max,
      priority: Priority.high,
      styleInformation: const BigTextStyleInformation(''),
    );

    final platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      'Waktunya Makan Siang!',
      'Kami akan mencarikan rekomendasi restoran untuk Anda',
      scheduledDate,
      platformDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'daily_reminder',
    );

    // Show immediate confirmation
    await showNotification(
      id: 0,
      title: 'Pengingat Makan Siang Diatur',
      body: 'Anda akan menerima notifikasi setiap hari pukul 11:00',
      payload: 'setup_confirmation',
    );
  }

  Future<bool> getNotificationPreference() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isNotificationEnabled') ?? false;
  }

  Future<void> setNotificationPreference(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isNotificationEnabled', value);
  }

  Future<void> cancelScheduledNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  Future<List<PendingNotificationRequest>> pendingNotificationRequests() async {
    final List<PendingNotificationRequest> pendingNotificationRequests =
        await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    return pendingNotificationRequests;
  }

  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }
}
