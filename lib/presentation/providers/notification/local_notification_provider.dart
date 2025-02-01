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
    // Get tomorrow at 11:00 AM
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1, 11, 0);
    
    // If it's before 11 AM, schedule for today at 11 AM
    if (now.hour < 11) {
      return DateTime(now.year, now.month, now.day, 11, 0);
    }
    
    return tomorrow;
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
