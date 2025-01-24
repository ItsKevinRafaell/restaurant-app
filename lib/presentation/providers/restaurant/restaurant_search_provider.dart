import 'package:flutter/widgets.dart';
import 'package:restaurant_app/data/api_services.dart';
import 'package:restaurant_app/presentation/providers/restaurant/static/restaurant_exception.dart';
import 'package:restaurant_app/presentation/providers/restaurant/static/restaurant_search_result_state.dart';

class RestaurantSearchProvider extends ChangeNotifier {
  final ApiServices _apiServices;
  final searchController = TextEditingController();

  RestaurantSearchProvider(this._apiServices);

  RestaurantSearchResultState _resultState = RestaurantSearchNoneState();

  RestaurantSearchResultState get resultState => _resultState;

  Future<void> searchRestaurants(String query) async {
    try {
      _resultState = RestaurantSearchLoadingState();
      notifyListeners();

      await Future.delayed(const Duration(seconds: 2));
      final results = await _apiServices.searchRestaurants(query);

      if (results.error == true) {
        throw RestaurantException('Terjadi kesalahan saat mencari restoran.');
      } else {
        _resultState = RestaurantSearchLoadedState(results.restaurants!);
      }
    } on RestaurantException catch (e) {
      _resultState = RestaurantSearchErrorState(e.message);
    } on Exception catch (e) {
      _resultState = RestaurantSearchErrorState(getUserFriendlyErrorMessage(e));
    } finally {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
