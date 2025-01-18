import 'package:restaurant_app/data/models/restaurant_list_model.dart';

sealed class RestaurantListResultState {}

class RestaurantListNoneState extends RestaurantListResultState {}

class RestaurantListLoadingState extends RestaurantListResultState {}

class RestaurantListErrorState extends RestaurantListResultState {
  final String error;

  RestaurantListErrorState(this.error);
}

class RestaurantListLoadedState extends RestaurantListResultState {
  final List<Restaurant> data;

  RestaurantListLoadedState(this.data);
}
