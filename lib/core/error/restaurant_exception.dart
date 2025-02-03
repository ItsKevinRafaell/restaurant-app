class RestaurantException implements Exception {
  final String message;

  RestaurantException(this.message);

  @override
  String toString() => message;
}
