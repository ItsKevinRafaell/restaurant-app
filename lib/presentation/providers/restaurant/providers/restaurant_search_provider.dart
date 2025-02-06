import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:restaurant_app/core/error/restaurant_exception.dart';
import 'package:restaurant_app/data/datasources/local/local_database_service.dart';
import 'package:restaurant_app/data/datasources/remote/api_services.dart';
import 'package:restaurant_app/data/repositories/restaurant_repository_impl.dart';
import 'package:restaurant_app/domain/usecases/search_restaurants.dart';
import 'package:restaurant_app/presentation/providers/restaurant/states/restaurant_search_result_state.dart';

class RestaurantSearchProvider extends ChangeNotifier {
  final SearchRestaurants searchRestaurants;
  final TextEditingController searchController = TextEditingController();

  RestaurantSearchProvider(ApiServices apiServices)
      : searchRestaurants = SearchRestaurants(
          RestaurantRepositoryImpl(
            apiServices,
            LocalDatabaseService(),
          ),
        );

  String? _message;
  String? get message => _message;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  RestaurantSearchResultState _resultState = RestaurantSearchInitialState();
  RestaurantSearchResultState get resultState => _resultState;

  Future<void> searchRestaurantsByQuery(String query) async {
    try {
      _resultState = RestaurantSearchLoadingState();
      notifyListeners();

      final result = await searchRestaurants.execute(query);
      if (result.restaurants?.isEmpty ?? true) {
        _resultState =
            RestaurantSearchErrorState(message: 'Tidak ada restoran');
      } else {
        _resultState = RestaurantSearchLoadedState(data: result.restaurants!);
      }
      notifyListeners();
    } on RestaurantException catch (e) {
      _message = e.message;
      _resultState = RestaurantSearchErrorState(message: _message!);
    } on SocketException catch (e) {
      _message = e.message;
      _resultState = RestaurantSearchErrorState(message: _message!);
    } on TimeoutException catch (e) {
      _message = e.message;
      _resultState = RestaurantSearchErrorState(message: _message!);
    } catch (e) {
      _message = 'An unexpected error occurred: ${e.toString()}';
      _resultState = RestaurantSearchErrorState(message: _message!);
    } finally {
      notifyListeners();
    }
  }
}
