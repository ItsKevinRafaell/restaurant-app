import 'package:flutter/widgets.dart';
import 'package:restaurant_app/data/api_services.dart';
import 'package:restaurant_app/presentation/providers/restaurant/static/restaurant_detail_result_state.dart';
import 'package:restaurant_app/presentation/providers/restaurant/static/restaurant_exception.dart';

class RestaurantDetailProvider extends ChangeNotifier {
  final ApiServices _apiServices;
  String? imageUrl;
  bool _isDescriptionExpanded = false;

  bool get isDescriptionExpanded => _isDescriptionExpanded;

  RestaurantDetailProvider(this._apiServices);

  RestaurantDetailResultState _resultState = RestaurantDetailNoneState();

  RestaurantDetailResultState get resultState => _resultState;

  void setRestaurantImage(String url) {
    imageUrl = url;
    notifyListeners();
  }

  void toggleDescriptionExpanded() {
    _isDescriptionExpanded = !_isDescriptionExpanded;
    notifyListeners();
  }

  Future<void> fetchRestaurantDetail(String id) async {
    try {
      _resultState = RestaurantDetailLoadingState();
      notifyListeners();

      final result = await _apiServices.getRestaurantDetail(id);

      if (result.error == true) {
        throw RestaurantException(
            result.message ?? 'Terjadi kesalahan saat memuat detail restoran.');
      } else {
        _resultState = RestaurantDetailLoadedState(result);
        debugPrint('RestaurantDetailProvider: ${result.restaurant!.menus}');
      }
    } on RestaurantException catch (e) {
      _resultState = RestaurantDetailErrorState(e.message);
    } on Exception catch (e) {
      _resultState = RestaurantDetailErrorState(getUserFriendlyErrorMessage(e));
    } finally {
      notifyListeners();
    }
  }
}
