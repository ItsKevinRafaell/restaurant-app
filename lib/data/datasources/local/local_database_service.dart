import 'package:restaurant_app/domain/entities/restaurant_detail_model.dart';
import 'package:sqflite/sqflite.dart';

class LocalDatabaseService {
  static const String _databaseName = 'restaurant-app.db';
  static const String _tableName = 'favorites';
  static const int _version = 1;

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

  Future<void> _createTables(Database database) async {
    await database.execute(
      """CREATE TABLE $_tableName(
      id_restaurant TEXT PRIMARY KEY,          
      name TEXT NOT NULL,
      description TEXT,
      address TEXT,
      pictureId TEXT,
      city TEXT NOT NULL,
      rating REAL
    )""",
    );
  }

  Future<Database> _initializeDb() async {
    return openDatabase(
      _databaseName,
      version: _version,
      onCreate: (Database database, int version) async {
        await _createTables(database);
      },
    );
  }

  Future<int> insertRestaurant(DetailRestaurant restaurant) async {
    try {
      if (restaurant.id == null) {
        throw Exception('Restaurant ID cannot be null');
      }

      final db = await database;

      final exists = await isFavorite(restaurant.id!);
      if (exists) {
        return 0;
      }

      final data = {
        "id_restaurant": restaurant.id,
        "name": restaurant.name ?? '',
        "description": restaurant.description ?? '',
        "address": restaurant.address ?? '',
        "pictureId": restaurant.pictureId ?? '',
        "city": restaurant.city ?? '',
        "rating": restaurant.rating ?? 0.0,
      };

      return await db.insert(
        _tableName,
        data,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw Exception('Failed to insert restaurant: $e');
    }
  }

  Future<int> removeRestaurant(String idRestaurant) async {
    try {
      final db = await database;
      return await db.delete(
        _tableName,
        where: "id_restaurant = ?",
        whereArgs: [idRestaurant],
      );
    } catch (e) {
      throw Exception('Failed to remove restaurant: $e');
    }
  }

  Future<bool> isFavorite(String idRestaurant) async {
    try {
      final db = await database;
      final results = await db.query(
        _tableName,
        where: "id_restaurant = ?",
        whereArgs: [idRestaurant],
      );
      return results.isNotEmpty;
    } catch (e) {
      throw Exception('Failed to check favorite status: $e');
    }
  }

  Future<List<DetailRestaurant>> getAllRestaurants() async {
    try {
      final db = await database;
      final results = await db.query(_tableName);

      return results.map((result) {
        return DetailRestaurant.fromMapSqlite({
          'id_restaurant': result['id_restaurant'] as String?,
          'name': result['name'] as String?,
          'description': result['description'] as String?,
          'address': result['address'] as String?,
          'pictureId': result['pictureId'] as String?,
          'city': result['city'] as String?,
          'rating': result['rating'] as double?,
        });
      }).toList();
    } catch (e) {
      throw Exception('Failed to get all restaurants: $e');
    }
  }
}
