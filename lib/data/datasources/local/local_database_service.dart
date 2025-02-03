import 'package:restaurant_app/domain/entities/restaurant_detail_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/foundation.dart';

class LocalDatabaseService {
  static const String _databaseName = 'restaurant-app.db';
  static const String _tableName = 'favorites';
  static const int _version = 1;

  static const String _columnId = 'id_restaurant';
  static const String _columnName = 'name';
  static const String _columnDescription = 'description';
  static const String _columnAddress = 'address';
  static const String _columnPictureId = 'pictureId';
  static const String _columnCity = 'city';
  static const String _columnRating = 'rating';

  static final LocalDatabaseService _instance =
      LocalDatabaseService._internal();
  factory LocalDatabaseService() => _instance;
  LocalDatabaseService._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initializeDb();
    return _database!;
  }

  Future<Database> _initializeDb() async {
    return openDatabase(
      _databaseName,
      version: _version,
      onCreate: _createTables,
    );
  }

  Future<void> _createTables(Database database, int version) async {
    await database.execute(
      """CREATE TABLE $_tableName(
      $_columnId TEXT PRIMARY KEY,          
      $_columnName TEXT NOT NULL,
      $_columnDescription TEXT,
      $_columnAddress TEXT,
      $_columnPictureId TEXT,
      $_columnCity TEXT NOT NULL,
      $_columnRating REAL
    )""",
    );
  }

  Map<String, dynamic> _restaurantToMap(RestaurantDetail restaurant) {
    return {
      _columnId: restaurant.id,
      _columnName: restaurant.name ?? '',
      _columnDescription: restaurant.description ?? '',
      _columnAddress: restaurant.address ?? '',
      _columnPictureId: restaurant.pictureId ?? '',
      _columnCity: restaurant.city ?? '',
      _columnRating: restaurant.rating ?? 0.0,
    };
  }

  RestaurantDetail _mapToRestaurant(Map<String, dynamic> map) {
    return RestaurantDetail.fromMapSqlite({
      'id_restaurant': map[_columnId] as String?,
      'name': map[_columnName] as String?,
      'description': map[_columnDescription] as String?,
      'address': map[_columnAddress] as String?,
      'pictureId': map[_columnPictureId] as String?,
      'city': map[_columnCity] as String?,
      'rating': map[_columnRating] as double?,
    });
  }

  Future<void> _handleDatabaseError(String operation, dynamic error) async {
    debugPrint('Failed to $operation: $error');
    throw Exception('Failed to $operation: $error');
  }

  Future<int> insertRestaurant(RestaurantDetail restaurant) async {
    try {
      if (restaurant.id == null) {
        throw Exception('Restaurant ID cannot be null');
      }

      final db = await database;

      final exists = await isFavorite(restaurant.id!);
      if (exists) {
        return 0;
      }

      return await db.insert(
        _tableName,
        _restaurantToMap(restaurant),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      await _handleDatabaseError('insert restaurant', e);
      return 0;
    }
  }

  Future<int> removeRestaurant(String idRestaurant) async {
    try {
      final db = await database;
      return await db.delete(
        _tableName,
        where: "$_columnId = ?",
        whereArgs: [idRestaurant],
      );
    } catch (e) {
      await _handleDatabaseError('remove restaurant', e);
      return 0;
    }
  }

  Future<bool> isFavorite(String idRestaurant) async {
    try {
      final db = await database;
      final results = await db.query(
        _tableName,
        where: "$_columnId = ?",
        whereArgs: [idRestaurant],
      );
      return results.isNotEmpty;
    } catch (e) {
      await _handleDatabaseError('check favorite status', e);
      return false;
    }
  }

  Future<List<RestaurantDetail>> getAllRestaurants() async {
    try {
      final db = await database;
      final results = await db.query(_tableName);

      return results
          .map(
            (result) => _mapToRestaurant(result),
          )
          .toList();
    } catch (e) {
      await _handleDatabaseError('get all restaurants', e);
      return [];
    }
  }
}
