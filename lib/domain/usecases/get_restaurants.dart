import 'package:restaurant_app/domain/entities/restaurant_list_model.dart';
import 'package:restaurant_app/domain/repositories/restaurant_repository.dart';

class GetRestaurants {
  final RestaurantRepository repository;

  GetRestaurants(this.repository);

  Future<RestaurantListModel> execute() {
    return repository.getRestaurants();
  }
}
