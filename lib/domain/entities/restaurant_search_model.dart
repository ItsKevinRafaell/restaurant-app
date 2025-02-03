import 'dart:convert';

import 'package:restaurant_app/domain/entities/restaurant_list_model.dart';

class RestaurantSearchModel {
  final bool? error;
  final int? founded;
  final List<Restaurant>? restaurants;

  RestaurantSearchModel({
    this.error,
    this.founded,
    this.restaurants,
  });

  factory RestaurantSearchModel.fromJson(String str) =>
      RestaurantSearchModel.fromMap(
        json.decode(str),
      );

  String toJson() => json.encode(
        toMap(),
      );

  factory RestaurantSearchModel.fromMap(Map<String, dynamic> json) =>
      RestaurantSearchModel(
        error: json["error"],
        founded: json["founded"],
        restaurants: json["restaurants"] == null
            ? []
            : List<Restaurant>.from(
                json["restaurants"]!.map(
                  (x) => Restaurant.fromMap(x),
                ),
              ),
      );

  Map<String, dynamic> toMap() => {
        "error": error,
        "founded": founded,
        "restaurants": restaurants == null
            ? []
            : List<dynamic>.from(
                restaurants!.map(
                  (x) => x.toMap(),
                ),
              ),
      };
}
