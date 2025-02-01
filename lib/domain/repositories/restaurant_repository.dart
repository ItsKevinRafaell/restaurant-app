import 'package:restaurant_app/domain/entities/restaurant_detail_model.dart';
import 'package:restaurant_app/domain/entities/restaurant_list_model.dart';
import 'package:restaurant_app/domain/entities/restaurant_review_model.dart';
import 'package:restaurant_app/domain/entities/restaurant_search_model.dart';

abstract class RestaurantRepository {
  Future<RestaurantListModel> getRestaurants();
  Future<RestaurantDetailModel> getRestaurantDetail(String id);
  Future<RestaurantSearchModel> searchRestaurants(String query);
  Future<RestaurantReviewModel> postRestaurantReview(String id, String name, String review);
  Future<void> addToFavorites(String restaurantId);
  Future<void> removeFromFavorites(String restaurantId);
  Future<bool> isFavorite(String restaurantId);
}
