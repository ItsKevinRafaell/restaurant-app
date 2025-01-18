import 'package:flutter/widgets.dart';
import 'package:restaurant_app/data/api_services.dart';
import 'package:restaurant_app/presentation/providers/restaurant/restaurant_list_result_state.dart';

class RestaurantListProvider extends ChangeNotifier {
  final ApiServices _apiServices;

  RestaurantListProvider(this._apiServices);

  RestaurantListResultState _resultState = RestaurantListNoneState();

  RestaurantListResultState get resultState => _resultState;

  Future<void> fetchRestaurants() async {
    try {
      _resultState = RestaurantListLoadingState();
      notifyListeners();

      final result = await _apiServices.getRestaurants();

      if (result == true) {
        _resultState = RestaurantListErrorState(result.message!);
      } else {
        _resultState = RestaurantListLoadedState(result.restaurants!);
      }
      notifyListeners();
    } on Exception catch (e) {
      _resultState = RestaurantListErrorState(e.toString());
      notifyListeners();
    }
  }
}
