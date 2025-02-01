import 'package:flutter/material.dart';
import 'package:restaurant_app/data/datasources/remote/api_services.dart';
import 'package:restaurant_app/domain/entities/restaurant_review_model.dart';

class RestaurantReviewProvider extends ChangeNotifier {
  final ApiServices apiService;

  RestaurantReviewProvider({required this.apiService});

  bool _isLoading = false;
  String _message = '';
  final List<RestaurantReviewModel> _reviews = [];

  bool get isLoading => _isLoading;
  String get message => _message;
  List<RestaurantReviewModel> get reviews => _reviews;

  Future<bool> postReview(String id, String name, String review) async {
    try {
      _isLoading = true;
      notifyListeners();

      final result = await apiService.postReview(id, name, review);
      // _reviews = result;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _message = 'Error: $e';
      notifyListeners();
      return false;
    }
  }
}
