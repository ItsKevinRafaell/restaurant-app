import 'package:flutter/widgets.dart';
import 'package:restaurant_app/data/api_services.dart';
import 'package:restaurant_app/presentation/providers/restaurant/static/restaurant_exception.dart';
import 'package:restaurant_app/presentation/providers/restaurant/static/restaurant_list_result_state.dart';

class RestaurantListProvider extends ChangeNotifier {
  final ApiServices _apiServices;

  RestaurantListProvider(this._apiServices);

  RestaurantListResultState _resultState = RestaurantListNoneState();

  RestaurantListResultState get resultState => _resultState;

  Future<void> fetchRestaurants() async {
    try {
      _resultState = RestaurantListLoadingState();
      notifyListeners();

      await Future.delayed(const Duration(seconds: 1));
      final result = await _apiServices.getRestaurants();

      if (result.error == true) {
        throw RestaurantException(
            result.message ?? 'Terjadi kesalahan saat memuat data restoran.');
      } else {
        _resultState = RestaurantListLoadedState(result.restaurants!);
      }
    } on RestaurantException catch (e) {
      _resultState = RestaurantListErrorState(e.message);
    } on Exception catch (e) {
      _resultState = RestaurantListErrorState(getUserFriendlyErrorMessage(e));
    } finally {
      notifyListeners();
    }
  }
}
