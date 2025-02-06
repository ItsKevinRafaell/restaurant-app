import 'package:restaurant_app/domain/entities/restaurant_review_model.dart';

abstract class RestaurantReviewState {
  const RestaurantReviewState();
}

class RestaurantReviewInitialState extends RestaurantReviewState {
  const RestaurantReviewInitialState();
}

class RestaurantReviewLoadingState extends RestaurantReviewState {
  const RestaurantReviewLoadingState();
}

class RestaurantReviewSuccessState extends RestaurantReviewState {
  final RestaurantReviewModel review;
  final String message;

  const RestaurantReviewSuccessState({
    required this.review,
    required this.message,
  });
}

class RestaurantReviewErrorState extends RestaurantReviewState {
  final String message;

  const RestaurantReviewErrorState({
    required this.message,
  });
}
