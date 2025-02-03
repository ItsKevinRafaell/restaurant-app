import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:restaurant_app/core/error/restaurant_exception.dart';
import 'package:restaurant_app/data/datasources/remote/api_services.dart';
import 'package:restaurant_app/domain/entities/restaurant_list_model.dart';
import 'package:restaurant_app/domain/entities/restaurant_search_model.dart';
import 'package:restaurant_app/presentation/providers/restaurant/providers/restaurant_search_provider.dart';
import 'package:restaurant_app/presentation/providers/restaurant/states/restaurant_search_result_state.dart';

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
      when(() => mockApiServices.searchRestaurants(searchQuery)).thenAnswer(
        (_) async => RestaurantSearchModel(
          error: false,
          founded: 1,
          restaurants: mockRestaurants,
        ),
      );

      
      await provider.searchRestaurantsByQuery(searchQuery);

      
      verify(() => mockApiServices.searchRestaurants(searchQuery)).called(1);
      expect(provider.resultState, isA<RestaurantSearchLoadedState>());
      expect(
        (provider.resultState as RestaurantSearchLoadedState).data,
        mockRestaurants,
      );
    });

    test('should return EmptyState when no restaurants found', () async {
      
      when(() => mockApiServices.searchRestaurants(searchQuery)).thenAnswer(
        (_) async => RestaurantSearchModel(
          error: false,
          founded: 0,
          restaurants: [],
        ),
      );

      
      await provider.searchRestaurantsByQuery(searchQuery);

      
      expect(provider.resultState, isA<RestaurantSearchErrorState>());
    });

    test(
        'should return ErrorState with server error message when RestaurantException occurs',
        () async {
      
      const errorMessage = 'Server error';
      when(() => mockApiServices.searchRestaurants(searchQuery))
          .thenThrow(RestaurantException(errorMessage));

      
      await provider.searchRestaurantsByQuery(searchQuery);

      
      expect(provider.resultState, isA<RestaurantSearchErrorState>());
      expect(
        (provider.resultState as RestaurantSearchErrorState).message,
        errorMessage,
      );
    });

    test(
        'should return ErrorState with no internet message when SocketException occurs',
        () async {
      
      when(() => mockApiServices.searchRestaurants(searchQuery))
          .thenThrow(const SocketException('Network is unreachable'));

      
      await provider.searchRestaurantsByQuery(searchQuery);

      
      expect(provider.resultState, isA<RestaurantSearchErrorState>());
      expect(
        (provider.resultState as RestaurantSearchErrorState).message,
        contains('Network is unreachable'),
      );
    });

    test(
        'should return ErrorState with timeout message when TimeoutException occurs',
        () async {
      
      when(() => mockApiServices.searchRestaurants(searchQuery))
          .thenThrow(TimeoutException('Request timeout'));

      
      await provider.searchRestaurantsByQuery(searchQuery);

      
      expect(provider.resultState, isA<RestaurantSearchErrorState>());
      expect(
        (provider.resultState as RestaurantSearchErrorState).message,
        contains('Request timeout'),
      );
    });
  });
}
