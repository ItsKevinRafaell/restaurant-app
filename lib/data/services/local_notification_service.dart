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
  static const String _restaurantChannelId = 'restaurant_notification';
  static const String _restaurantChannelName = 'Restaurant Notification';
  static const Importance _importance = Importance.max;
  static const Priority _priority = Priority.high;

  Future<void> init() async {
    const androidSettings = AndroidInitializationSettings('app_icon');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await flutterLocalNotificationsPlugin.initialize(
      InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
      ),
      onDidReceiveNotificationResponse: (response) {
        if (response.payload != null) {
          selectNotificationStream.add(response.payload);
        }
      },
    );
  }

  Future<bool> isAndroidPermissionGranted() async {
    final androidPlugin =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    return await androidPlugin?.areNotificationsEnabled() ?? false;
  }

  Future<bool> _requestAndroidNotificationsPermission() async {
    final androidPlugin =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    return await androidPlugin?.requestNotificationsPermission() ?? false;
  }

  Future<bool> _requestExactAlarmsPermission() async {
    final androidPlugin =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    return await androidPlugin?.requestExactAlarmsPermission() ?? false;
  }

  Future<bool?> requestPermissions() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final notificationEnabled = await isAndroidPermissionGranted();
      final alarmEnabled = await _requestExactAlarmsPermission();
      if (!notificationEnabled) {
        return await _requestAndroidNotificationsPermission() && alarmEnabled;
      }
      return notificationEnabled && alarmEnabled;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      final iOSPlugin =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
      return await iOSPlugin?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
    return false;
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    required String payload,
    String? channelId,
    String? channelName,
    String? sound,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      channelId ?? _restaurantChannelId,
      channelName ?? _restaurantChannelName,
      importance: _importance,
      priority: _priority,
      sound: sound != null ? RawResourceAndroidNotificationSound(sound) : null,
    );

    final darwinDetails = DarwinNotificationDetails(
      sound: sound != null ? '$sound.aiff' : null,
      presentSound: sound != null,
    );

    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      NotificationDetails(android: androidDetails, iOS: darwinDetails),
      payload: payload,
    );
  }

  Future<void> configureLocalTimeZone() async {
    tz.initializeTimeZones();
    final timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(
      tz.getLocation(timeZoneName),
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
}
