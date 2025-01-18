abstract class RestaurantReviewResultState {}

class RestaurantReviewNoneState extends RestaurantReviewResultState {}

class RestaurantReviewLoadingState extends RestaurantReviewResultState {}

class RestaurantReviewLoadedState extends RestaurantReviewResultState {
  final String data;

  RestaurantReviewLoadedState(this.data);
}

class RestaurantReviewErrorState extends RestaurantReviewResultState {
  final String error;

  RestaurantReviewErrorState(this.error);
}
