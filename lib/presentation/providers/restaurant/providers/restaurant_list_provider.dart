import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:restaurant_app/core/error/restaurant_exception.dart';
import 'package:restaurant_app/data/datasources/local/local_database_service.dart';
import 'package:restaurant_app/data/datasources/remote/api_services.dart';
import 'package:restaurant_app/data/repositories/restaurant_repository_impl.dart';
import 'package:restaurant_app/domain/usecases/get_restaurants.dart';
import 'package:restaurant_app/presentation/providers/restaurant/states/restaurant_list_state.dart';

class RestaurantListProvider extends ChangeNotifier {
  final GetRestaurants getRestaurants;

  RestaurantListProvider(ApiServices apiServices)
      : getRestaurants = GetRestaurants(
          RestaurantRepositoryImpl(
            apiServices,
            LocalDatabaseService(),
          ),
        ) {
    _resultState = RestaurantListNoneState();
  }

  late RestaurantListResultState _resultState;
  RestaurantListResultState get resultState => _resultState;

  Future<void> fetchRestaurants() async {
    try {
      _resultState = RestaurantListLoadingState();
      notifyListeners();

      final result = await getRestaurants.execute();
      if (result.restaurants?.isEmpty ?? true) {
        _resultState = RestaurantListErrorState(message: 'Tidak ada restoran');
      } else {
        _resultState = RestaurantListLoadedState(data: result.restaurants!);
      }
      notifyListeners();
    } on RestaurantException catch (e) {
      _resultState = RestaurantListErrorState(message: e.message);
      notifyListeners();
    } on SocketException catch (_) {
      _resultState = RestaurantListErrorState(
        message: 'Tidak ada koneksi internet. Silakan periksa jaringan Anda.',
      );
      notifyListeners();
    } on TimeoutException catch (_) {
      _resultState = RestaurantListErrorState(
        message: 'Permintaan waktu habis. Silakan coba lagi.',
      );
      notifyListeners();
    } catch (_) {
      _resultState = RestaurantListErrorState(
        message: 'Terjadi kesalahan. Silakan coba lagi nanti.',
      );
      notifyListeners();
    }
  }
}
