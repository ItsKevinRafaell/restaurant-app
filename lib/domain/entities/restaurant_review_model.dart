import 'dart:convert';

class RestaurantReviewModel {
  final bool error;
  final String message;
  final List<CustomerReview> customerReviews;

  RestaurantReviewModel({
    required this.error,
    required this.message,
    required this.customerReviews,
  });

  factory RestaurantReviewModel.fromRawJson(String str) =>
      RestaurantReviewModel.fromJson(
        json.decode(str),
      );

  String toRawJson() => json.encode(
        toJson(),
      );

  factory RestaurantReviewModel.fromJson(Map<String, dynamic> json) =>
      RestaurantReviewModel(
        error: json["error"],
        message: json["message"],
        customerReviews: List<CustomerReview>.from(
          json["customerReviews"].map(
            (x) => CustomerReview.fromJson(x),
          ),
        ),
      );

  Map<String, dynamic> toJson() => {
        "error": error,
        "message": message,
        "customerReviews": List<dynamic>.from(
          customerReviews.map(
            (x) => x.toJson(),
          ),
        ),
      };
}

class CustomerReview {
  final String name;
  final String review;
  final String date;

  CustomerReview({
    required this.name,
    required this.review,
    required this.date,
  });

  factory CustomerReview.fromRawJson(String str) => CustomerReview.fromJson(
        json.decode(str),
      );

  String toRawJson() => json.encode(
        toJson(),
      );

  factory CustomerReview.fromJson(Map<String, dynamic> json) => CustomerReview(
        name: json["name"],
        review: json["review"],
        date: json["date"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "review": review,
        "date": date,
      };
}
