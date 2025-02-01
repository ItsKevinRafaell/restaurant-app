import 'package:restaurant_app/domain/entities/restaurant_search_model.dart';
import 'package:restaurant_app/domain/repositories/restaurant_repository.dart';

class SearchRestaurants {
  final RestaurantRepository repository;

  SearchRestaurants(this.repository);

  Future<RestaurantSearchModel> execute(String query) {
    return repository.searchRestaurants(query);
  }
}
