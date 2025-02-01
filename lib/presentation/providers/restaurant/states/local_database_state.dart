import 'package:restaurant_app/domain/entities/restaurant_detail_model.dart';

abstract class LocalDatabaseResultState {
  const LocalDatabaseResultState();
}

class LocalDatabaseNoneState extends LocalDatabaseResultState {}

class LocalDatabaseLoadingState extends LocalDatabaseResultState {}

class LocalDatabaseErrorState extends LocalDatabaseResultState {
  final String message;

  LocalDatabaseErrorState({required this.message});
}

class LocalDatabaseLoadedState extends LocalDatabaseResultState {
  final List<DetailRestaurant> data;

  LocalDatabaseLoadedState(this.data);
}
