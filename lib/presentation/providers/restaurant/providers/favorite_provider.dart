import 'package:flutter/material.dart';
import 'package:restaurant_app/data/datasources/local/local_database_service.dart';
import 'package:restaurant_app/domain/entities/restaurant_detail_model.dart';
import 'package:restaurant_app/presentation/providers/restaurant/providers/local_database_provider.dart';

class FavoriteProvider extends ChangeNotifier {
  final LocalDatabaseService _localDatabaseService;
  final LocalDatabaseProvider? _localDatabaseProvider;

  FavoriteProvider({
    LocalDatabaseProvider? localDatabaseProvider,
  })  : _localDatabaseService = LocalDatabaseService(),
        _localDatabaseProvider = localDatabaseProvider;

  bool _isFavorite = false;
  bool get isFavorite => _isFavorite;

  Future<void> checkFavoriteStatus(String id) async {
    try {
      _isFavorite = await _localDatabaseService.isFavorite(id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error checking favorite status: $e');
      _isFavorite = false;
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(DetailRestaurant restaurant) async {
    if (restaurant.id == null) return;

    try {
      final newState = !_isFavorite;

      if (newState) {
        final result = await _localDatabaseService.insertRestaurant(restaurant);
        if (result <= 0) return;
      } else {
        final result =
            await _localDatabaseService.removeRestaurant(restaurant.id!);
        if (result <= 0) return;
      }

      _isFavorite = newState;
      notifyListeners();

      await _localDatabaseProvider?.loadAllRestaurants();
    } catch (e) {
      debugPrint('Error toggling favorite: $e');

      await checkFavoriteStatus(restaurant.id!);
    }
  }
}
