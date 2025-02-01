import 'package:restaurant_app/domain/entities/restaurant_list_model.dart';

abstract class RestaurantSearchResultState {
  const RestaurantSearchResultState();
}

class RestaurantSearchInitialState extends RestaurantSearchResultState {}

class RestaurantSearchLoadingState extends RestaurantSearchResultState {}

class RestaurantSearchEmptyState extends RestaurantSearchResultState {}

class RestaurantSearchErrorState extends RestaurantSearchResultState {
  final String message;

  RestaurantSearchErrorState({required this.message});
}

class RestaurantSearchLoadedState extends RestaurantSearchResultState {
  final List<Restaurant> data;

  RestaurantSearchLoadedState({required this.data});
}
