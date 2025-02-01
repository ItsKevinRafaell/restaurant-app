import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:restaurant_app/data/datasources/local/local_database_service.dart';
import 'package:restaurant_app/domain/entities/restaurant_detail_model.dart';
import 'package:restaurant_app/presentation/providers/restaurant/providers/local_database_provider.dart';
import 'package:restaurant_app/presentation/providers/restaurant/states/local_database_state.dart';

class MockLocalDatabaseService extends Mock implements LocalDatabaseService {}

void main() {
  late MockLocalDatabaseService mockService;
  late LocalDatabaseProvider provider;

  final mockRestaurant = DetailRestaurant(
    id: "rqdv5juczeskfw1e867",
    name: "Melting Pot",
    description: "Lorem ipsum dolor sit amet",
    city: "Medan",
    address: "Jl. Pandeglang no 19",
    pictureId: "14",
    categories: [Category(name: "Indonesia")],
    menus: Menu(
      foods: [Category(name: "Nasi Goreng")],
      drinks: [Category(name: "Es Teh")],
    ),
    rating: 4.2,
    customerReviews: [],
  );

  setUp(() {
    mockService = MockLocalDatabaseService();
    provider = LocalDatabaseProvider(mockService);
  });

  group('local database provider', () {
    test('should return NoneState when provider is initialized', () {
      expect(provider.resultState, isA<LocalDatabaseNoneState>());
      expect(provider.restaurantList, isNull);
      expect(provider.message, isEmpty);
    });

    test(
        'should return LoadedState with restaurants when loadAllRestaurants is successful',
        () async {
      // arrange
      final mockRestaurants = [mockRestaurant];
      when(() => mockService.getAllRestaurants())
          .thenAnswer((_) async => mockRestaurants);

      // act
      await provider.loadAllRestaurants();

      // assert
      verify(() => mockService.getAllRestaurants()).called(1);
      expect(provider.resultState, isA<LocalDatabaseLoadedState>());
      expect(
        (provider.resultState as LocalDatabaseLoadedState).data,
        mockRestaurants,
      );
      expect(provider.restaurantList, equals(mockRestaurants));
    });

    test('should return ErrorState with message when loadAllRestaurants fails',
        () async {
      // arrange
      const errorMessage = 'Failed to load restaurants';
      when(() => mockService.getAllRestaurants())
          .thenThrow(Exception(errorMessage));

      // act
      await provider.loadAllRestaurants();

      // assert
      expect(provider.resultState, isA<LocalDatabaseErrorState>());
      expect(
        (provider.resultState as LocalDatabaseErrorState).message,
        contains(errorMessage),
      );
    });

    test(
        'should add restaurant and reload list when addRestaurant is successful',
        () async {
      // arrange
      when(() => mockService.insertRestaurant(mockRestaurant))
          .thenAnswer((_) async => 1);
      when(() => mockService.getAllRestaurants())
          .thenAnswer((_) async => [mockRestaurant]);

      // act
      await provider.addRestaurant(mockRestaurant);

      // assert
      verify(() => mockService.insertRestaurant(mockRestaurant)).called(1);
      verify(() => mockService.getAllRestaurants()).called(1);
      expect(provider.message, equals('Success'));
      expect(provider.restaurantList, equals([mockRestaurant]));
    });

    test('should set error message when addRestaurant fails', () async {
      // arrange
      const errorMessage = 'Failed to add restaurant';
      when(() => mockService.insertRestaurant(mockRestaurant))
          .thenThrow(Exception(errorMessage));

      // act
      await provider.addRestaurant(mockRestaurant);

      // assert
      expect(provider.message, contains(errorMessage));
    });

    test(
        'should remove restaurant and reload list when removeRestaurant is successful',
        () async {
      // arrange
      const restaurantId = "rqdv5juczeskfw1e867";
      when(() => mockService.removeRestaurant(restaurantId))
          .thenAnswer((_) async => 1);
      when(() => mockService.getAllRestaurants()).thenAnswer((_) async => []);

      // act
      await provider.removeRestaurant(restaurantId);

      // assert
      verify(() => mockService.removeRestaurant(restaurantId)).called(1);
      verify(() => mockService.getAllRestaurants()).called(1);
      expect(provider.message, equals('Success'));
      expect(provider.restaurantList, isEmpty);
    });

    test('should set error message when removeRestaurant fails', () async {
      // arrange
      const restaurantId = "rqdv5juczeskfw1e867";
      const errorMessage = 'Failed to remove restaurant';
      when(() => mockService.removeRestaurant(restaurantId))
          .thenThrow(Exception(errorMessage));

      // act
      await provider.removeRestaurant(restaurantId);

      // assert
      expect(provider.message, contains(errorMessage));
    });
  });
}
