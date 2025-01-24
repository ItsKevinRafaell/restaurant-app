import 'package:flutter/material.dart';
import 'package:restaurant_app/data/api_services.dart';
import 'package:restaurant_app/presentation/providers/restaurant/static/restaurant_exception.dart';
import 'package:restaurant_app/presentation/providers/restaurant/static/restaurant_review_result_state.dart';

class RestaurantReviewProvider with ChangeNotifier {
  final ApiServices _apiServices;
  bool isLoading = false;
  String? _nameError;
  String? _reviewError;

  String? get nameError => _nameError;
  String? get reviewError => _reviewError;

  RestaurantReviewProvider(this._apiServices);

  final RestaurantReviewResultState _resultState = RestaurantReviewNoneState();

  RestaurantReviewResultState get resultState => _resultState;

  Future<void> postReview(String id, String name, String review) async {
    try {
      isLoading = true;
      notifyListeners();
      await Future.delayed(const Duration(seconds: 2));
      await _apiServices.postReview(id, name, review);
      isLoading = false;
      notifyListeners();
    } on RestaurantException catch (e) {
      isLoading = false;
      notifyListeners();
      throw RestaurantException(e.message);
    } on Exception catch (e) {
      isLoading = false;
      notifyListeners();
      throw Exception(getUserFriendlyErrorMessage(e));
    }
  }
}
