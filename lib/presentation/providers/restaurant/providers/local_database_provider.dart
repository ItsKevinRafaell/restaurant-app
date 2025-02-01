import 'package:flutter/foundation.dart';
import 'package:restaurant_app/data/datasources/local/local_database_service.dart';
import 'package:restaurant_app/domain/entities/restaurant_detail_model.dart';
import 'package:restaurant_app/presentation/providers/restaurant/states/local_database_state.dart';

class LocalDatabaseProvider extends ChangeNotifier {
  final LocalDatabaseService _service;

  LocalDatabaseProvider(this._service);

  String _message = "";
  String get message => _message;

  List<DetailRestaurant>? _restaurantList;
  List<DetailRestaurant>? get restaurantList => _restaurantList;

  DetailRestaurant? _restaurant;
  DetailRestaurant? get restaurant => _restaurant;

  LocalDatabaseResultState _resultState = LocalDatabaseNoneState();
  LocalDatabaseResultState get resultState => _resultState;

  Future<void> loadAllRestaurants() async {
    try {
      _resultState = LocalDatabaseLoadingState();
      notifyListeners();

      final detailRestaurants = await _service.getAllRestaurants();
      _restaurantList = detailRestaurants;
      _resultState = LocalDatabaseLoadedState(detailRestaurants);
      notifyListeners();
    } catch (e) {
      _resultState = LocalDatabaseErrorState(message: e.toString());
      notifyListeners();
    }
  }

  Future<void> addRestaurant(DetailRestaurant restaurant) async {
    try {
      await _service.insertRestaurant(restaurant);
      await loadAllRestaurants();
      _message = 'Success';
    } catch (e) {
      _message = e.toString();
    }
    notifyListeners();
  }

  Future<void> removeRestaurant(String id) async {
    try {
      await _service.removeRestaurant(id);
      await loadAllRestaurants();
      _message = 'Success';
    } catch (e) {
      _message = e.toString();
    }
    notifyListeners();
  }

  Future<bool> isRestaurantExist(String id) async {
    final restaurantExist = await _service.isFavorite(id);
    return restaurantExist;
  }
}
