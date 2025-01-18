import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:restaurant_app/data/models/restaurant_detail_model.dart';
import 'package:restaurant_app/data/models/restaurant_list_model.dart';
import 'package:restaurant_app/data/models/restaurant_search_model.dart';

class ApiServices {
  final String baseUrl = 'https://restaurant-api.dicoding.dev';

  Future<RestaurantListModel> getRestaurants() async {
    final response = await http.get(Uri.parse('$baseUrl/list'));

    if (response.statusCode == 200) {
      return RestaurantListModel.fromJson(response.body);
    } else {
      throw Exception('Failed to load restaurants');
    }
  }

  Future<RestaurantDetailModel> getRestaurantDetail(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/detail/$id'));

    if (response.statusCode == 200) {
      return RestaurantDetailModel.fromJson(response.body);
    } else {
      throw Exception(
        'Failed to load restaurant details',
      );
    }
  }

  Future<RestaurantSearchModel> searchRestaurants(String query) async {
    final response = await http.get(Uri.parse('$baseUrl/search?q=$query'));

    if (response.statusCode == 200) {
      return RestaurantSearchModel.fromJson(response.body);
    } else {
      throw Exception('Failed to search restaurants');
    }
  }

  Future<void> postReview(String id, String name, String review) async {
    final response = await http.post(
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
  }
}
