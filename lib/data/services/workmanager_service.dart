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
    try {
      final apiService = ApiServices();
      final repository =
          RestaurantRepositoryImpl(apiService, LocalDatabaseService());
      final getRestaurants = GetRestaurants(repository);
      final notificationService = LocalNotificationService();
      await notificationService.init();

      // Fetch restaurants from API
      final restaurantResult = await getRestaurants.execute();

      if (restaurantResult.restaurants != null &&
          restaurantResult.restaurants!.isNotEmpty) {
        // Get a random restaurant
        final random = Random();
        final randomRestaurant = restaurantResult
            .restaurants![random.nextInt(restaurantResult.restaurants!.length)];

        // Show notification with restaurant data
        await notificationService.showRestaurantNotification(
          id: 1,
          title: 'Restaurant Recommendation: ${randomRestaurant.name}',
          body:
              '${randomRestaurant.description}\nRating: ${randomRestaurant.rating}⭐',
          payload: randomRestaurant.id!,
        );
        debugPrint('WorkManager: Notification sent successfully');
        return true;
      }
      return false;
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
    await Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
    await WorkmanagerService().runPeriodicTask();
    debugPrint('WorkManager: Initialized');
  }

  Future<void> runPeriodicTask() async {
    // Cancel any existing tasks first
    await Workmanager().cancelByUniqueName(taskName);

    // Calculate initial delay to 11:00 AM
    final now = DateTime.now();
    var elevenAM = DateTime(now.year, now.month, now.day, 11, 0);

    // If it's past 11 AM, schedule for next day
    if (now.isAfter(elevenAM)) {
      elevenAM = elevenAM.add(const Duration(days: 1));
    }

    final initialDelay = elevenAM.difference(now);
    debugPrint(
        'WorkManager: Scheduling task with initial delay of ${initialDelay.inHours} hours and ${initialDelay.inMinutes % 60} minutes');

    await Workmanager().registerPeriodicTask(
      taskName,
      taskName,
      frequency: const Duration(days: 1),
      initialDelay: initialDelay,
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
      existingWorkPolicy: ExistingWorkPolicy.replace,
    );
    debugPrint('WorkManager: Task scheduled successfully');
  }

  Future<void> cancelAllTask() async {
    await Workmanager().cancelAll();
    debugPrint('WorkManager: All tasks cancelled');
  }
}
