import 'package:restaurant_app/domain/entities/restaurant_review_model.dart';
import 'package:restaurant_app/domain/repositories/restaurant_repository.dart';

class PostRestaurantReview {
  final RestaurantRepository repository;

  PostRestaurantReview(this.repository);

  Future<RestaurantReviewModel> execute(String id, String name, String review) {
    return repository.postRestaurantReview(id, name, review);
  }
}
