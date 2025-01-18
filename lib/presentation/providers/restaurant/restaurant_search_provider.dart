import 'package:flutter/widgets.dart';
import 'package:restaurant_app/data/api_services.dart';
import 'package:restaurant_app/presentation/providers/restaurant/restaurant_search_result_state.dart';

class RestaurantSearchProvider extends ChangeNotifier {
  final ApiServices _apiServices;
  final TextEditingController searchController = TextEditingController();

  RestaurantSearchProvider(this._apiServices);

  RestaurantSearchResultState _resultState = RestaurantSearchNoneState();

  RestaurantSearchResultState get resultState => _resultState;

  Future<void> searchRestaurants(String query) async {
    try {
      _resultState = RestaurantSearchLoadingState();
      notifyListeners();

      final results = await _apiServices.searchRestaurants(query);

      if (results == true) {
        _resultState = RestaurantSearchLoadedState([]);
      } else {
        _resultState = RestaurantSearchLoadedState(results.restaurants!);
      }
    } catch (e) {
      _resultState =
          RestaurantSearchErrorState('Gagal memuat hasil pencarian: $e');
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
