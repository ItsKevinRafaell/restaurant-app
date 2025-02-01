import 'package:restaurant_app/data/datasources/remote/api_services.dart';
import 'package:restaurant_app/data/datasources/local/local_database_service.dart';
import 'package:restaurant_app/domain/entities/restaurant_detail_model.dart';
import 'package:restaurant_app/domain/entities/restaurant_list_model.dart';
import 'package:restaurant_app/domain/entities/restaurant_review_model.dart';
import 'package:restaurant_app/domain/entities/restaurant_search_model.dart';
import 'package:restaurant_app/domain/repositories/restaurant_repository.dart';

class RestaurantRepositoryImpl implements RestaurantRepository {
  final ApiServices apiServices;
  final LocalDatabaseService localDatabaseService;

  RestaurantRepositoryImpl(this.apiServices, this.localDatabaseService);

  @override
  Future<RestaurantListModel> getRestaurants() async {
    return await apiServices.getRestaurants();
  }

  @override
  Future<RestaurantDetailModel> getRestaurantDetail(String id) async {
    return await apiServices.getRestaurantDetail(id);
  }

  @override
  Future<RestaurantSearchModel> searchRestaurants(String query) async {
    return await apiServices.searchRestaurants(query);
  }

  @override
  Future<RestaurantReviewModel> postRestaurantReview(
      String id, String name, String review) async {
    return await apiServices.postReview(id, name, review);
  }

  @override
  Future<void> addToFavorites(String restaurantId) async {
    final restaurant = await getRestaurantDetail(restaurantId);
    await localDatabaseService.insertRestaurant(restaurant.restaurant!);
  }

  @override
  Future<void> removeFromFavorites(String restaurantId) async {
    await localDatabaseService.removeRestaurant(restaurantId);
  }

  @override
  Future<bool> isFavorite(String restaurantId) async {
    return await localDatabaseService.isFavorite(restaurantId);
  }
}
