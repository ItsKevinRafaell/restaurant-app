import 'package:restaurant_app/domain/entities/restaurant_detail_model.dart';

abstract class RestaurantDetailResultState {
  const RestaurantDetailResultState();
}

class RestaurantDetailLoadingState extends RestaurantDetailResultState {}

class RestaurantDetailErrorState extends RestaurantDetailResultState {
  final String message;

  RestaurantDetailErrorState({required this.message});
}

class RestaurantDetailLoadedState extends RestaurantDetailResultState {
  final DetailRestaurant data;

  RestaurantDetailLoadedState({required this.data});
}
