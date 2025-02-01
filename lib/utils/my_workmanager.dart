import 'package:restaurant_app/data/datasources/local/local_database_service.dart';
import 'package:restaurant_app/data/datasources/remote/api_services.dart';
import 'package:restaurant_app/data/repositories/restaurant_repository_impl.dart';
import 'package:restaurant_app/data/services/local_notification_service.dart';
import 'package:restaurant_app/domain/usecases/get_restaurants.dart';
import 'package:workmanager/workmanager.dart';

class MyWorkManager {
  static void callbackDispatcher() {
    Workmanager().executeTask((task, inputData) async {
      switch (task) {
        case 'restaurantTask':
          final apiService = ApiServices();
          final repository = RestaurantRepositoryImpl(
            apiService,
            LocalDatabaseService(),
          );
          final getRestaurants = GetRestaurants(repository);
          final notificationService = LocalNotificationService();

          try {
            final result = await getRestaurants.execute();
            if (result.restaurants?.isNotEmpty ?? false) {
              final restaurant = result.restaurants![0];
              await notificationService.showNotification(
                id: 1,
                title: restaurant.name ?? '',
                body: restaurant.description ?? '',
                payload: restaurant.id ?? '',
              );
            }
            return true;
          } catch (e) {
            return false;
          }
        default:
          return false;
      }
    });
  }
}
