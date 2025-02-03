import 'package:flutter/material.dart';
import 'package:restaurant_app/data/services/local_notification_service.dart';

class LocalNotificationProvider extends ChangeNotifier {
  final LocalNotificationService _service;
  bool _isScheduled = false;
  bool _permissionGranted = false;

  LocalNotificationProvider(this._service) {
    _initializeNotifications();
  }

  bool get isScheduled => _isScheduled;
  bool get permission => _permissionGranted;

  DateTime getNextNotificationTime() {
    final now = DateTime.now();
    return now.hour < 11
        ? DateTime(now.year, now.month, now.day, 11, 0)
        : DateTime(now.year, now.month, now.day + 1, 11, 0);
  }

  Future<void> _initializeNotifications() async {
    await _service.init();
    await _getNotificationPreference();
    _permissionGranted = await _service.isAndroidPermissionGranted();
    notifyListeners();
  }

  Future<void> _getNotificationPreference() async {
    _isScheduled = await _service.getNotificationPreference();
    notifyListeners();
  }

  Future<void> enableNotification(bool value) async {
    await _service.setNotificationPreference(value);
    _isScheduled = value;
    notifyListeners();
  }

  Future<void> requestPermissions() async {
    await _service.requestPermissions();
    _permissionGranted = await _service.isAndroidPermissionGranted();
    notifyListeners();
  }
}
