import 'package:flutter/material.dart';
import 'package:restaurant_app/data/datasources/local/local_database_service.dart';
import 'package:restaurant_app/domain/entities/restaurant_detail_model.dart';
import 'package:restaurant_app/domain/repositories/restaurant_repository.dart';

enum RestaurantDetailState { initial, loading, loaded, error }

class RestaurantDetailProvider extends ChangeNotifier {
  final RestaurantRepository _repository;

  RestaurantDetailProvider({
    required RestaurantRepository repository,
  }) : _repository = repository;

  RestaurantDetailState _state = RestaurantDetailState.initial;
  RestaurantDetailState get state => _state;

  DetailRestaurant? _restaurant;
  DetailRestaurant? get restaurant => _restaurant;

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

  void _safeNotifyListeners() {
    if (!_disposed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_disposed) {
          notifyListeners();
        }
      });
    }
  }

  void setRestaurantImage(String image) {
    if (_disposed) return;
    _restaurantImage = image;
    _safeNotifyListeners();
  }

  Future<void> fetchRestaurantDetail(String id) async {
    if (_disposed) return;

    try {
      _setState(RestaurantDetailState.loading);

      final result = await _repository.getRestaurantDetail(id);
      if (result.restaurant == null) {
        throw Exception('Restaurant data is null');
      }

      if (!_disposed) {
        _restaurant = result.restaurant;
        _setState(RestaurantDetailState.loaded);
      }
    } catch (e) {
      if (!_disposed) {
        _message = e.toString();
        _setState(RestaurantDetailState.error);
      }
    }
  }

  void _setState(RestaurantDetailState newState) {
    if (!_disposed) {
      _state = newState;
      _safeNotifyListeners();
    }
  }

  void toggleDescription() {
    if (_disposed) return;
    _isDescriptionExpanded = !_isDescriptionExpanded;
    _safeNotifyListeners();
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
      _isFavorite = !_isFavorite; // Revert on error
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
