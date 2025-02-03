import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:restaurant_app/domain/entities/restaurant_detail_model.dart';
import 'package:restaurant_app/domain/repositories/restaurant_repository.dart';
import 'package:restaurant_app/presentation/providers/restaurant/providers/restaurant_detail_provider.dart';
import 'package:restaurant_app/presentation/providers/restaurant/states/restaurant_detail_state.dart';

class MockRestaurantRepository extends Mock implements RestaurantRepository {}

void main() {
  late MockRestaurantRepository mockRepository;
  late RestaurantDetailProvider provider;
  const String restaurantId = "rqdv5juczeskfw1e867";

  final mockRestaurant = RestaurantDetailModel(
    error: false,
    message: "success",
    restaurant: DetailRestaurant(
      id: restaurantId,
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
    ),
  );

  setUp(() {
    mockRepository = MockRestaurantRepository();
    provider = RestaurantDetailProvider(repository: mockRepository);
  });

  group('restaurant detail provider', () {
    test('should return initial state when provider is initialized', () {
      expect(provider.state, equals(RestaurantDetailNoneState));
      expect(provider.restaurant, isNull);
      expect(provider.message, isNull);
    });

    test(
        'should return loaded state with restaurant data when fetch is successful',
        () async {
      // arrange
      when(() => mockRepository.getRestaurantDetail(restaurantId))
          .thenAnswer((_) async => mockRestaurant);

      // act
      await provider.fetchRestaurantDetail(restaurantId);

      // assert
      verify(() => mockRepository.getRestaurantDetail(restaurantId)).called(1);
      expect(provider.state, equals(RestaurantDetailLoadedState));
      expect(provider.restaurant, equals(mockRestaurant.restaurant));
    });

    test('should return error state with message when fetch fails', () async {
      // arrange
      const errorMessage = 'Failed to load restaurant detail';
      when(() => mockRepository.getRestaurantDetail(restaurantId))
          .thenThrow(Exception(errorMessage));

      // act
      await provider.fetchRestaurantDetail(restaurantId);

      // assert
      expect(provider.state, equals(RestaurantDetailErrorState));
      expect(provider.message, contains(errorMessage));
    });

    test(
        'should toggle description expanded state when toggleDescriptionExpanded is called',
        () {
      // arrange
      final initialState = provider.isDescriptionExpanded;

      // act
      provider.toggleDescriptionExpanded();

      // assert
      expect(provider.isDescriptionExpanded, equals(!initialState));
    });

    test('should update restaurant image when setRestaurantImage is called',
        () {
      // arrange
      const imageUrl = 'https://restaurant-api.dicoding.dev/images/medium/14';

      // act
      provider.setRestaurantImage(imageUrl);

      // assert
      expect(provider.restaurantImage, equals(imageUrl));
    });

    test('should toggle favorite status when toggleFavoriteStatus is called',
        () async {
      // arrange
      final initialState = provider.isFavorite;

      // act
      await provider.toggleFavoriteStatus(restaurantId);

      // assert
      expect(provider.isFavorite, equals(!initialState));
    });
  });
}
