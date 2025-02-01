import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:restaurant_app/data/datasources/remote/api_services.dart';
import 'package:restaurant_app/domain/entities/restaurant_review_model.dart';
import 'package:restaurant_app/presentation/providers/restaurant/providers/restaurant_review_provider.dart';

class MockApiServices extends Mock implements ApiServices {}

void main() {
  late MockApiServices mockApiServices;
  late RestaurantReviewProvider provider;
  const String restaurantId = "rqdv5juczeskfw1e867";
  const String reviewerName = "John Doe";
  const String reviewText = "Great restaurant!";

  final mockReviewResponse = RestaurantReviewModel(
    error: false,
    message: "success",
    customerReviews: [
      CustomerReview(
        name: reviewerName,
        review: reviewText,
        date: "2024-01-31",
      ),
    ],
  );

  setUp(() {
    mockApiServices = MockApiServices();
    provider = RestaurantReviewProvider(apiService: mockApiServices);
  });

  group('restaurant review provider', () {
    test('should return initial state when provider is initialized', () {
      expect(provider.isLoading, false);
      expect(provider.message, '');
      expect(provider.reviews, isEmpty);
    });

    test('should post review successfully', () async {
      when(() => mockApiServices.postReview(restaurantId, reviewerName, reviewText))
          .thenAnswer((_) async => mockReviewResponse);

      final result = await provider.postReview(restaurantId, reviewerName, reviewText);

      expect(result, true);
      expect(provider.isLoading, false);
      verify(() => mockApiServices.postReview(restaurantId, reviewerName, reviewText))
          .called(1);
    });

    test('should return error when post review fails', () async {
      when(() => mockApiServices.postReview(restaurantId, reviewerName, reviewText))
          .thenThrow(Exception('Failed to post review'));

      final result = await provider.postReview(restaurantId, reviewerName, reviewText);

      expect(result, false);
      expect(provider.isLoading, false);
      verify(() => mockApiServices.postReview(restaurantId, reviewerName, reviewText))
          .called(1);
    });

    test('should set loading state while posting review', () async {
      when(() => mockApiServices.postReview(restaurantId, reviewerName, reviewText))
          .thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 100));
        return mockReviewResponse;
      });

      final future = provider.postReview(restaurantId, reviewerName, reviewText);
      expect(provider.isLoading, true);

      await future;
      expect(provider.isLoading, false);
    });
  });
}
