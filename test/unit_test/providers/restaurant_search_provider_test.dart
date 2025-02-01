import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:restaurant_app/core/error/exceptions.dart';
import 'package:restaurant_app/data/datasources/remote/api_services.dart';
import 'package:restaurant_app/domain/entities/restaurant_list_model.dart';
import 'package:restaurant_app/domain/entities/restaurant_search_model.dart';
import 'package:restaurant_app/presentation/providers/restaurant/providers/restaurant_search_provider.dart';
import 'package:restaurant_app/presentation/providers/restaurant/states/restaurant_search_state.dart';

class MockApiServices extends Mock implements ApiServices {}

void main() {
  late MockApiServices mockApiServices;
  late RestaurantSearchProvider provider;
  const String searchQuery = "Melting Pot";

  final mockRestaurants = [
    Restaurant(
      id: "rqdv5juczeskfw1e867",
      name: "Melting Pot",
      description: "Lorem ipsum dolor sit amet",
      pictureId: "14",
      city: "Medan",
      rating: 4.2,
    ),
  ];

  setUp(() {
    mockApiServices = MockApiServices();
    provider = RestaurantSearchProvider(mockApiServices);
  });

  group('restaurant search provider', () {
    test('should return InitialState when provider is initialized', () {
      expect(provider.resultState, isA<RestaurantSearchInitialState>());
    });

    test(
        'should return LoadedState with restaurants data when search is successful',
        () async {
      // arrange
      when(() => mockApiServices.searchRestaurants(searchQuery)).thenAnswer(
        (_) async => RestaurantSearchModel(
          error: false,
          founded: 1,
          restaurants: mockRestaurants,
        ),
      );

      // act
      await provider.searchRestaurantsByQuery(searchQuery);

      // assert
      verify(() => mockApiServices.searchRestaurants(searchQuery)).called(1);
      expect(provider.resultState, isA<RestaurantSearchLoadedState>());
      expect(
        (provider.resultState as RestaurantSearchLoadedState).data,
        mockRestaurants,
      );
    });

    test('should return EmptyState when no restaurants found', () async {
      // arrange
      when(() => mockApiServices.searchRestaurants(searchQuery)).thenAnswer(
        (_) async => RestaurantSearchModel(
          error: false,
          founded: 0,
          restaurants: [],
        ),
      );

      // act
      await provider.searchRestaurantsByQuery(searchQuery);

      // assert
      expect(provider.resultState, isA<RestaurantSearchEmptyState>());
    });

    test(
        'should return ErrorState with server error message when RestaurantException occurs',
        () async {
      // arrange
      const errorMessage = 'Server error';
      when(() => mockApiServices.searchRestaurants(searchQuery))
          .thenThrow(RestaurantException(errorMessage));

      // act
      await provider.searchRestaurantsByQuery(searchQuery);

      // assert
      expect(provider.resultState, isA<RestaurantSearchErrorState>());
      expect(
        (provider.resultState as RestaurantSearchErrorState).message,
        errorMessage,
      );
    });

    test(
        'should return ErrorState with no internet message when SocketException occurs',
        () async {
      // arrange
      when(() => mockApiServices.searchRestaurants(searchQuery))
          .thenThrow(const SocketException('Network is unreachable'));

      // act
      await provider.searchRestaurantsByQuery(searchQuery);

      // assert
      expect(provider.resultState, isA<RestaurantSearchErrorState>());
      expect(
        (provider.resultState as RestaurantSearchErrorState).message,
        contains('Network is unreachable'),
      );
    });

    test(
        'should return ErrorState with timeout message when TimeoutException occurs',
        () async {
      // arrange
      when(() => mockApiServices.searchRestaurants(searchQuery))
          .thenThrow(TimeoutException('Request timeout'));

      // act
      await provider.searchRestaurantsByQuery(searchQuery);

      // assert
      expect(provider.resultState, isA<RestaurantSearchErrorState>());
      expect(
        (provider.resultState as RestaurantSearchErrorState).message,
        contains('Request timeout'),
      );
    });
  });
}
