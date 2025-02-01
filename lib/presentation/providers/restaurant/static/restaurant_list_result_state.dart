abstract class RestaurantListState {}

class RestaurantListNoneState extends RestaurantListState {}

class RestaurantListLoadingState extends RestaurantListState {}

class RestaurantListLoadedState extends RestaurantListState {
  final dynamic result;

  RestaurantListLoadedState(this.result);
}

class RestaurantListErrorState extends RestaurantListState {
  final String message;

  RestaurantListErrorState(this.message);
}
