import 'dart:convert';

import 'package:restaurant_app/domain/entities/restaurant_list_model.dart';

class RestaurantDetailModel {
  final bool? error;
  final String? message;
  final DetailRestaurant? restaurant;

  RestaurantDetailModel({
    this.error,
    this.message,
    this.restaurant,
  });

  factory RestaurantDetailModel.fromJson(String str) =>
      RestaurantDetailModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory RestaurantDetailModel.fromMap(Map<String, dynamic> json) {
    return RestaurantDetailModel(
      error: json["error"],
      message: json["message"],
      restaurant: json["restaurant"] == null
          ? null
          : DetailRestaurant.fromMap(json["restaurant"]),
    );
  }

  Map<String, dynamic> toMap() => {
        "error": error,
        "message": message,
        "restaurant": restaurant?.toMap(),
      };
}

class DetailRestaurant {
  final String? id;
  final String? name;
  final String? description;
  final String? city;
  final String? address;
  final String? pictureId;
  final List<Category>? categories;
  final Menu? menus;
  final double? rating;
  final List<CustomerReview>? customerReviews;

  DetailRestaurant({
    this.id,
    this.name,
    this.description,
    this.city,
    this.address,
    this.pictureId,
    this.categories,
    this.menus,
    this.rating,
    this.customerReviews,
  });

  factory DetailRestaurant.fromJson(String str) =>
      DetailRestaurant.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory DetailRestaurant.fromMap(Map<String, dynamic> json) =>
      DetailRestaurant(
        id: json["id"],
        name: json["name"],
        description: json["description"],
        city: json["city"],
        address: json["address"],
        pictureId: json["pictureId"],
        categories: json["categories"] == null
            ? []
            : List<Category>.from(
                json["categories"]!.map((x) => Category.fromMap(x))),
        menus: json["menus"] == null ? null : Menu.fromMap(json["menus"]),
        rating: json["rating"]?.toDouble(),
        customerReviews: json["customerReviews"] == null
            ? []
            : List<CustomerReview>.from(
                json["customerReviews"]!.map((x) => CustomerReview.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
        "description": description,
        "city": city,
        "address": address,
        "pictureId": pictureId,
        "categories": categories == null
            ? []
            : List<dynamic>.from(categories!.map((x) => x.toMap())),
        "menus": menus?.toMap(),
        "rating": rating,
        "customerReviews": customerReviews == null
            ? []
            : List<dynamic>.from(customerReviews!.map((x) => x.toMap())),
      };

  DetailRestaurant filterData() {
    return DetailRestaurant(
      id: id,
      name: name,
      description: description,
      address: address,
      pictureId: pictureId,
      city: city,
      rating: rating,
    );
  }

  factory DetailRestaurant.fromMapSqlite(Map<String, dynamic> map) {
    return DetailRestaurant(
      id: map['id_restaurant'] as String?,
      name: map['name'] as String?,
      description: map['description'] as String?,
      address: map['address'] as String?,
      pictureId: map['pictureId'] as String?,
      city: map['city'] as String?,
      rating: map['rating'] as double?,
    );
  }

  Restaurant toRestaurant() {
    return Restaurant(
      id: id,
      name: name,
      city: city,
      pictureId: pictureId,
      description: description,
      rating: rating,
    );
  }
}

class Category {
  final String? name;

  Category({
    this.name,
  });

  factory Category.fromJson(String str) => Category.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Category.fromMap(Map<String, dynamic> json) => Category(
        name: json["name"],
      );

  Map<String, dynamic> toMap() => {
        "name": name,
      };
}

class CustomerReview {
  final String? name;
  final String? review;
  final String? date;

  CustomerReview({
    this.name,
    this.review,
    this.date,
  });

  factory CustomerReview.fromJson(String str) =>
      CustomerReview.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory CustomerReview.fromMap(Map<String, dynamic> json) => CustomerReview(
        name: json["name"],
        review: json["review"],
        date: json["date"],
      );

  Map<String, dynamic> toMap() => {
        "name": name,
        "review": review,
        "date": date,
      };
}

class Menu {
  final List<Category>? foods;
  final List<Category>? drinks;

  Menu({
    this.foods,
    this.drinks,
  });

  factory Menu.fromJson(String str) => Menu.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Menu.fromMap(Map<String, dynamic> json) => Menu(
        foods: json["foods"] == null
            ? []
            : List<Category>.from(
                json["foods"]!.map((x) => Category.fromMap(x))),
        drinks: json["drinks"] == null
            ? []
            : List<Category>.from(
                json["drinks"]!.map((x) => Category.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
        "foods": foods == null
            ? []
            : List<dynamic>.from(foods!.map((x) => x.toMap())),
        "drinks": drinks == null
            ? []
            : List<dynamic>.from(drinks!.map((x) => x.toMap())),
      };
}
