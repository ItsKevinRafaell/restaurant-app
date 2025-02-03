import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:restaurant_app/core/error/restaurant_exception.dart';
import 'package:restaurant_app/domain/entities/restaurant_detail_model.dart';
import 'package:restaurant_app/domain/repositories/restaurant_repository.dart';
import 'package:restaurant_app/presentation/providers/restaurant/states/restaurant_detail_result_state.dart';

class RestaurantDetailProvider extends ChangeNotifier {
  final RestaurantRepository _repository;

  RestaurantDetailProvider({
    required RestaurantRepository repository,
  }) : _repository = repository;

  RestaurantDetailResultState _state = RestaurantDetailNoneState();
  RestaurantDetailResultState get state => _state;

  RestaurantDetail? _restaurant;
  RestaurantDetail? get restaurant => _restaurant;

  String? _message;
  String? get message => _message;

  bool _isDescriptionExpanded = false;
  bool get isDescriptionExpanded => _isDescriptionExpanded;

  String? _restaurantImage;
  String? get restaurantImage => _restaurantImage;

  bool _disposed = false;
  bool _isFavorite = false;
  bool get isFavorite => _isFavorite;

  void toggleDescriptionExpanded() {
    _isDescriptionExpanded = !_isDescriptionExpanded;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void setRestaurantImage(String image) {
    _restaurantImage = image;
    notifyListeners();
  }

  Future<void> fetchRestaurantDetail(String id) async {
    _state = RestaurantDetailLoadingState();
    notifyListeners();

    try {
      final result = await _repository.getRestaurantDetail(id);
      if (result.restaurant == null) {
        _message = 'Restaurant data is null';
        _state = RestaurantDetailErrorState(message: _message!);
      } else {
        _restaurant = result.restaurant;
        _state = RestaurantDetailLoadedState(data: _restaurant!);
      }
    } on RestaurantException catch (e) {
      _message = e.message;
      _state = RestaurantDetailErrorState(message: _message!);
    } on SocketException catch (_) {
      _message = 'No internet connection. Please check your network.';
      _state = RestaurantDetailErrorState(message: _message!);
    } on TimeoutException catch (_) {
      _message = 'Request timed out. Please try again.';
      _state = RestaurantDetailErrorState(message: _message!);
    } catch (e) {
      _message = 'An unexpected error occurred: ${e.toString()}';
      _state = RestaurantDetailErrorState(message: _message!);
    } finally {
      notifyListeners();
    }
  }

  void toggleDescription() {
    if (_disposed) return;
    _isDescriptionExpanded = !_isDescriptionExpanded;
    notifyListeners();
  }

  Future<void> toggleFavoriteStatus(String restaurantId) async {
    try {
      _isFavorite = !_isFavorite;
      notifyListeners();

      if (_isFavorite) {
        await _repository.addToFavorites(restaurantId);
      } else {
        await _repository.removeFromFavorites(restaurantId);
      }
    } catch (e) {
      _isFavorite = !_isFavorite;
    }
  }

  Future<void> checkFavoriteStatus(String restaurantId) async {
    try {
      _isFavorite = await _repository.isFavorite(restaurantId);
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to check favorite status: $e');
    }
  }
}
