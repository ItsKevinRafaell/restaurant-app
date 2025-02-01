import 'package:restaurant_app/domain/entities/restaurant_detail_model.dart';
import 'package:restaurant_app/domain/repositories/restaurant_repository.dart';

class GetRestaurantDetail {
  final RestaurantRepository repository;

  GetRestaurantDetail(this.repository);

  Future<RestaurantDetailModel> execute(String id) {
    return repository.getRestaurantDetail(id);
  }
}
