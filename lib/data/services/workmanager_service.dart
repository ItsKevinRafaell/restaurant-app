import 'dart:math';
import 'package:flutter/material.dart';
import 'package:restaurant_app/data/datasources/local/local_database_service.dart';
import 'package:restaurant_app/data/datasources/remote/api_services.dart';
import 'package:restaurant_app/data/repositories/restaurant_repository_impl.dart';
import 'package:restaurant_app/data/services/local_notification_service.dart';
import 'package:restaurant_app/domain/usecases/get_restaurants.dart';
import 'package:workmanager/workmanager.dart';

const String taskName = "dailyRestaurantReminder";

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    debugPrint('WorkManager: Starting task execution - $task at ${DateTime.now()}');
    
    try {
      final notificationService = LocalNotificationService();
      
      debugPrint('WorkManager: Initializing notification service');
      await notificationService.init();

      // Check notification permissions
      debugPrint('WorkManager: Checking notification permissions');
      final hasPermission = await notificationService.isAndroidPermissionGranted();
      if (!hasPermission) {
        debugPrint('WorkManager: Notification permission not granted');
        return false;
      }
      debugPrint('WorkManager: Notification permission granted');

      // First try to show a test notification
      debugPrint('WorkManager: Attempting to show test notification');
      await notificationService.showNotification(
        id: 999,
        title: 'Test Notification',
        body: 'This is a test notification from WorkManager at ${DateTime.now()}',
        payload: 'test',
      );
      debugPrint('WorkManager: Test notification sent successfully');

      // Now proceed with the restaurant notification
      debugPrint('WorkManager: Setting up services for restaurant notification');
      final apiService = ApiServices();
      final repository = RestaurantRepositoryImpl(apiService, LocalDatabaseService());
      final getRestaurants = GetRestaurants(repository);

      debugPrint('WorkManager: Fetching restaurants from API');
      final restaurantResult = await getRestaurants.execute();

      if (restaurantResult.restaurants == null || restaurantResult.restaurants!.isEmpty) {
        debugPrint('WorkManager: No restaurants found');
        return false;
      }
      debugPrint('WorkManager: Found ${restaurantResult.restaurants!.length} restaurants');

      // Get a random restaurant
      final random = Random();
      final randomRestaurant = restaurantResult.restaurants![random.nextInt(restaurantResult.restaurants!.length)];
      debugPrint('WorkManager: Selected random restaurant - ${randomRestaurant.name}');

      // Show restaurant notification
      debugPrint('WorkManager: Attempting to show restaurant notification');
      await notificationService.showRestaurantNotification(
        id: 1,
        title: 'Restaurant Recommendation: ${randomRestaurant.name}',
        body: '${randomRestaurant.description}\nRating: ${randomRestaurant.rating}⭐',
        payload: randomRestaurant.id!,
      );
      debugPrint('WorkManager: Restaurant notification sent successfully');
      
      return true;
    } catch (e, stackTrace) {
      debugPrint('WorkManager: Error executing task $task');
      debugPrint('Error: $e');
      debugPrint('StackTrace: $stackTrace');
      return false;
    }
  });
}

class WorkmanagerService {
  final Workmanager _workmanager;

  WorkmanagerService([Workmanager? workmanager])
      : _workmanager = workmanager ?? Workmanager();

  static Future<void> initializeWorkmanager() async {
    try {
      debugPrint('WorkManager: Starting initialization');
      await Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
      await WorkmanagerService().runPeriodicTask();
      debugPrint('WorkManager: Initialized successfully');
    } catch (e, stackTrace) {
      debugPrint('WorkManager: Error initializing - $e');
      debugPrint('StackTrace: $stackTrace');
    }
  }

  Future<void> runPeriodicTask() async {
    try {
      debugPrint('WorkManager: Starting to schedule periodic task');
      
      // Cancel any existing tasks first
      await _workmanager.cancelByUniqueName(taskName);
      debugPrint('WorkManager: Cancelled existing tasks');

      // For testing purposes, run every 15 minutes instead of daily at 11 AM
      await _workmanager.registerPeriodicTask(
        taskName,
        taskName,
        frequency: const Duration(minutes: 15), // Changed from daily to 15 minutes for testing
        initialDelay: const Duration(seconds: 10), // Start after 10 seconds for testing
        constraints: Constraints(
          networkType: NetworkType.connected,
        ),
        existingWorkPolicy: ExistingWorkPolicy.replace,
      );
      debugPrint('WorkManager: Task scheduled successfully - will run every 15 minutes');
    } catch (e, stackTrace) {
      debugPrint('WorkManager: Error scheduling task - $e');
      debugPrint('StackTrace: $stackTrace');
    }
  }

  Future<void> cancelAllTask() async {
    try {
      await _workmanager.cancelAll();
      debugPrint('WorkManager: All tasks cancelled successfully');
    } catch (e, stackTrace) {
      debugPrint('WorkManager: Error cancelling tasks - $e');
      debugPrint('StackTrace: $stackTrace');
    }
  }
}
