import 'package:restaurant_app/domain/entities/restaurant_list_model.dart';

abstract class RestaurantListResultState {
  const RestaurantListResultState();
}

class RestaurantListNoneState extends RestaurantListResultState {}

class RestaurantListLoadingState extends RestaurantListResultState {}

class RestaurantListEmptyState extends RestaurantListResultState {}

class RestaurantListErrorState extends RestaurantListResultState {
  final String message;

  RestaurantListErrorState({required this.message});
}

class RestaurantListLoadedState extends RestaurantListResultState {
  final List<Restaurant> data;

  RestaurantListLoadedState({required this.data});
}
