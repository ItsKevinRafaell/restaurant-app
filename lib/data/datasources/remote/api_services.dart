import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:restaurant_app/domain/entities/restaurant_detail_model.dart';
import 'package:restaurant_app/domain/entities/restaurant_list_model.dart';
import 'package:restaurant_app/domain/entities/restaurant_review_model.dart';
import 'package:restaurant_app/domain/entities/restaurant_search_model.dart';

class ApiServices {
  static const String baseUrl = 'https://restaurant-api.dicoding.dev';
  static var client = http.Client();

  // ApiServices({required this.client});

  Future<RestaurantListModel> getRestaurants() async {
    final response = await client.get(Uri.parse('$baseUrl/list'));

    if (response.statusCode == 200) {
      return RestaurantListModel.fromJson(response.body);
    } else {
      throw Exception('Failed to load restaurants');
    }
  }

  Future<RestaurantDetailModel> getRestaurantDetail(String id) async {
    final response = await client.get(Uri.parse('$baseUrl/detail/$id'));

    if (response.statusCode == 200) {
      return RestaurantDetailModel.fromJson(response.body);
    } else {
      throw Exception(
        'Failed to load restaurant details',
      );
    }
  }

  Future<RestaurantSearchModel> searchRestaurants(String query) async {
    final response = await client.get(Uri.parse('$baseUrl/search?q=$query'));

    if (response.statusCode == 200) {
      return RestaurantSearchModel.fromJson(response.body);
    } else {
      throw Exception('Failed to search restaurants');
    }
  }

  Future<RestaurantReviewModel> postReview(
      String id, String name, String review) async {
    final response = await client.post(
      Uri.parse('$baseUrl/review'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(
        <String, String>{
          'id': id,
          'name': name,
          'review': review,
        },
      ),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return RestaurantReviewModel.fromRawJson(response.body);
    } else {
      throw Exception('Failed to post review');
    }
  }
}
