import 'package:flutter/widgets.dart';
import 'package:restaurant_app/data/api_services.dart';
import 'package:restaurant_app/presentation/providers/restaurant/restaurant_detail_result_state.dart';

class RestaurantDetailProvider extends ChangeNotifier {
  final ApiServices _apiServices;

  RestaurantDetailProvider(this._apiServices);

  RestaurantDetailResultState _resultState = RestaurantDetailNoneState();

  RestaurantDetailResultState get resultState => _resultState;

  Future<void> fetchRestaurantDetail(String id) async {
    try {
      _resultState = RestaurantDetailLoadingState();
      notifyListeners();

      final result = await _apiServices.getRestaurantDetail(id);

      if (result.error == true) {
        _resultState = RestaurantDetailErrorState(result.message!);
        notifyListeners();
      } else {
        _resultState = RestaurantDetailLoadedState(result);
        notifyListeners();
      }
    } on Exception catch (e) {
      _resultState = RestaurantDetailErrorState(e.toString());
      notifyListeners();
    }
  }

  Future<void> postReview(String id, String name, String review) async {
    try {
      await _apiServices.postReview(id, name, review);
      debugPrint('Ulasan berhasil dikirim');
    } catch (e) {
      throw Exception('Gagal mengirim ulasan: $e');
    }
  }
}
