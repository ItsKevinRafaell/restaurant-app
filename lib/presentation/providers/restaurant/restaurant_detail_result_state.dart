import 'package:restaurant_app/data/models/restaurant_detail_model.dart';
import 'package:restaurant_app/data/models/restaurant_list_model.dart';

sealed class RestaurantDetailResultState {}

class RestaurantDetailNoneState extends RestaurantDetailResultState {}

class RestaurantDetailLoadingState extends RestaurantDetailResultState {}

class RestaurantDetailErrorState extends RestaurantDetailResultState {
  final String error;

  RestaurantDetailErrorState(this.error);
}

class RestaurantDetailLoadedState extends RestaurantDetailResultState {
  final RestaurantDetailModel data;

  RestaurantDetailLoadedState(this.data);
}
