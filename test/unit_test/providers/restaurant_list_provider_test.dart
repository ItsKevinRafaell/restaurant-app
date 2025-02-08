import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:restaurant_app/core/error/restaurant_exception.dart';
import 'package:restaurant_app/data/datasources/remote/api_services.dart';
import 'package:restaurant_app/domain/entities/restaurant_list_model.dart';
import 'package:restaurant_app/presentation/providers/restaurant/providers/restaurant_list_provider.dart';
import 'package:restaurant_app/presentation/providers/restaurant/states/restaurant_list_state.dart';

class MockApiServices extends Mock implements ApiServices {}

void main() {
  late MockApiServices mockApiServices;
  late RestaurantListProvider provider;
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
    provider = RestaurantListProvider(mockApiServices);
  });

  group('restaurant list provider', () {
    test('should return NoneState when provider is initialized', () {
      expect(
        provider.resultState,
        isA<RestaurantListNoneState>(),
      );
    });

    test(
        'should return LoadedState with restaurants data when fetch is successful',
        () async {
      when(
        () => mockApiServices.getRestaurants(),
      ).thenAnswer(
        (_) async => RestaurantListModel(
          error: false,
          message: "success",
          count: 1,
          restaurants: mockRestaurants,
        ),
      );

      await provider.fetchRestaurants();

      verify(
        () => mockApiServices.getRestaurants(),
      ).called(1);
      expect(
        provider.resultState,
        isA<RestaurantListLoadedState>(),
      );
      expect(
        (provider.resultState as RestaurantListLoadedState).data,
        mockRestaurants,
      );
    });

    test(
        'should return ErrorState with server error message when RestaurantException occurs',
        () async {
      const errorMessage = 'Server error';
      when(
        () => mockApiServices.getRestaurants(),
      ).thenThrow(
        RestaurantException(errorMessage),
      );

      await provider.fetchRestaurants();

      expect(
        provider.resultState,
        isA<RestaurantListErrorState>(),
      );
      expect(
        (provider.resultState as RestaurantListErrorState).message,
        errorMessage,
      );
    });

    test(
        'should return ErrorState with no internet message when SocketException occurs',
        () async {
      when(
        () => mockApiServices.getRestaurants(),
      ).thenThrow(
        const SocketException('Network is unreachable'),
      );

      await provider.fetchRestaurants();

      expect(
        provider.resultState,
        isA<RestaurantListErrorState>(),
      );
      expect(
        (provider.resultState as RestaurantListErrorState).message,
        'Tidak ada koneksi internet. Silakan periksa jaringan Anda.',
      );
    });

    test(
        'should return ErrorState with timeout message when TimeoutException occurs',
        () async {
      when(
        () => mockApiServices.getRestaurants(),
      ).thenThrow(
        TimeoutException('Request timeout'),
      );

      await provider.fetchRestaurants();

      expect(
        provider.resultState,
        isA<RestaurantListErrorState>(),
      );
      expect(
        (provider.resultState as RestaurantListErrorState).message,
        'Permintaan waktu habis. Silakan coba lagi.',
      );
    });

    test(
        'should return ErrorState with general error message when unknown Exception occurs',
        () async {
      when(
        () => mockApiServices.getRestaurants(),
      ).thenThrow(
        Exception('Unknown error'),
      );

      await provider.fetchRestaurants();

      expect(
        provider.resultState,
        isA<RestaurantListErrorState>(),
      );
      expect(
        (provider.resultState as RestaurantListErrorState).message,
        'Terjadi kesalahan. Silakan coba lagi nanti.',
      );
    });
  });
}
