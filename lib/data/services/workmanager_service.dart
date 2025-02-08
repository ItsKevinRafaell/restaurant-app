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
    debugPrint(
        'WorkManager: Starting task execution - $task at ${DateTime.now()}');

    try {
      final notificationService = LocalNotificationService();

      debugPrint('WorkManager: Initializing notification service');
      await notificationService.init();

      debugPrint('WorkManager: Checking notification permissions');
      final hasPermission =
          await notificationService.isAndroidPermissionGranted();
      if (!hasPermission) {
        debugPrint('WorkManager: Notification permission not granted');
        return false;
      }
      debugPrint('WorkManager: Notification permission granted');

      debugPrint(
          'WorkManager: Setting up services for restaurant notification');
      final apiService = ApiServices();
      final repository = RestaurantRepositoryImpl(
        apiService,
        LocalDatabaseService(),
      );
      final getRestaurants = GetRestaurants(repository);

      debugPrint('WorkManager: Fetching restaurants from API');
      final restaurantResult = await getRestaurants.execute();

      if (restaurantResult.restaurants == null ||
          restaurantResult.restaurants!.isEmpty) {
        debugPrint('WorkManager: No restaurants found');
        return false;
      }
      debugPrint(
          'WorkManager: Found ${restaurantResult.restaurants!.length} restaurants');

      final random = Random();
      final randomRestaurant = restaurantResult
          .restaurants![random.nextInt(restaurantResult.restaurants!.length)];
      debugPrint(
          'WorkManager: Selected random restaurant - ${randomRestaurant.name}');

      debugPrint('WorkManager: Attempting to show restaurant notification');
      await notificationService.showNotification(
        id: 1,
        title:
            'Rekomendasi Makan Siang dari Restoran Ternama: ${randomRestaurant.name}',
        body:
            '${randomRestaurant.description}\nRating: ${randomRestaurant.rating}⭐',
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
      await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
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

      final now = DateTime.now();
      final next11AM = DateTime(now.year, now.month, now.day, 11);
      Duration initialDelay;

      if (now.isAfter(next11AM)) {
        initialDelay = next11AM
            .add(
              const Duration(days: 1),
            )
            .difference(now);
      } else {
        initialDelay = next11AM.difference(now);
      }

      debugPrint('WorkManager: Initial delay until next 11 AM - $initialDelay');

      await _workmanager.cancelByUniqueName(taskName);
      debugPrint('WorkManager: Cancelled existing tasks');

      await _workmanager.registerPeriodicTask(
        taskName,
        taskName,
        frequency: const Duration(hours: 24),
        initialDelay: initialDelay,
        constraints: Constraints(
          networkType: NetworkType.connected,
        ),
        existingWorkPolicy: ExistingWorkPolicy.replace,
      );
      debugPrint(
          'WorkManager: Task scheduled successfully - will run daily at 11 AM');
    } catch (e, stackTrace) {
      debugPrint('WorkManager: Error scheduling task - $e');
      debugPrint('StackTrace: $stackTrace');
    }
  }
}
