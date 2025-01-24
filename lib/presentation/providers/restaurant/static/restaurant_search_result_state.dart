import 'package:restaurant_app/data/models/restaurant_list_model.dart';

abstract class RestaurantSearchResultState {}

class RestaurantSearchNoneState extends RestaurantSearchResultState {}

class RestaurantSearchLoadingState extends RestaurantSearchResultState {}

class RestaurantSearchLoadedState extends RestaurantSearchResultState {
  final List<Restaurant> restaurants;

  RestaurantSearchLoadedState(this.restaurants);
}

class RestaurantSearchErrorState extends RestaurantSearchResultState {
  final String error;

  RestaurantSearchErrorState(this.error);
}
