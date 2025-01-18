import 'package:flutter/material.dart';
import 'package:restaurant_app/data/api_services.dart';

class RestaurantReviewProvider with ChangeNotifier {
  final ApiServices _apiServices;

  RestaurantReviewProvider(this._apiServices);

  Future<void> postReview(String id, String name, String review) async {
    try {
      final response = await _apiServices.postReview(id, name, review);
    } catch (e) {
      debugPrint('Error posting review: $e');
      throw Exception('Gagal mengirim ulasan: $e');
    }
  }
}
