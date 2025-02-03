import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app/domain/entities/restaurant_list_model.dart';
import 'package:restaurant_app/presentation/pages/home_page.dart';
import 'package:restaurant_app/presentation/providers/restaurant/providers/local_database_provider.dart';
import 'package:restaurant_app/presentation/providers/restaurant/providers/restaurant_list_provider.dart';
import 'package:restaurant_app/presentation/providers/restaurant/states/restaurant_list_state.dart';

class MockRestaurantListProvider extends Mock
    implements RestaurantListProvider {}

class MockLocalDatabaseProvider extends Mock implements LocalDatabaseProvider {}

void main() {
  late MockRestaurantListProvider restaurantListProvider;
  late MockLocalDatabaseProvider localDatabaseProvider;
  late Widget widget;

  setUp(() {
    restaurantListProvider = MockRestaurantListProvider();
    localDatabaseProvider = MockLocalDatabaseProvider();

    when(() => restaurantListProvider.fetchRestaurants())
        .thenAnswer((_) async => Future<void>.value());

    widget = MaterialApp(
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider<RestaurantListProvider>(
            create: (context) => restaurantListProvider,
          ),
          ChangeNotifierProvider<LocalDatabaseProvider>(
            create: (context) => localDatabaseProvider,
          ),
        ],
        child: const HomePage(),
      ),
    );
  });

  group('HomePage Widget Test', () {
    testWidgets('should display loading indicator when state is loading',
        (tester) async {
      when(() => restaurantListProvider.resultState)
          .thenReturn(RestaurantListLoadingState());
      when(() => localDatabaseProvider.restaurantList).thenReturn([]);
      when(() => localDatabaseProvider.loadAllRestaurants())
          .thenAnswer((_) async => Future<void>.value());

      await tester.pumpWidget(widget);

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display error message when state is error',
        (tester) async {
      const errorMessage = 'Failed to load data';
      when(() => restaurantListProvider.resultState)
          .thenReturn(RestaurantListErrorState(message: errorMessage));
      when(() => localDatabaseProvider.restaurantList).thenReturn([]);
      when(() => localDatabaseProvider.loadAllRestaurants())
          .thenAnswer((_) async => Future<void>.value());

      await tester.pumpWidget(widget);

      expect(find.text('Gagal memuat data: $errorMessage'), findsOneWidget);
      expect(find.text('Coba Lagi'), findsOneWidget);

      await tester.tap(find.byType(ElevatedButton));
      verify(() => restaurantListProvider.fetchRestaurants()).called(2);
    });

    testWidgets('should display restaurant list when state is loaded',
        (tester) async {
      final mockRestaurants = [
        Restaurant(
          id: '1',
          name: 'Restaurant 1',
          description: 'Description 1',
          pictureId: 'pic1',
          city: 'City 1',
          rating: 4.5,
        ),
        Restaurant(
          id: '2',
          name: 'Restaurant 2',
          description: 'Description 2',
          pictureId: 'pic2',
          city: 'City 2',
          rating: 4.0,
        ),
      ];

      when(() => restaurantListProvider.resultState)
          .thenReturn(RestaurantListLoadedState(data: mockRestaurants));
      when(() => localDatabaseProvider.restaurantList).thenReturn([]);
      when(() => localDatabaseProvider.loadAllRestaurants())
          .thenAnswer((_) async => Future<void>.value());

      await tester.pumpWidget(widget);

      expect(find.text('Berikut adalah daftar restoran yang tersedia'),
          findsOneWidget);

      expect(find.text('Restaurant 1'), findsOneWidget);
      expect(find.text('Restaurant 2'), findsOneWidget);
    });

    testWidgets('should call refresh when pull to refresh is triggered',
        (tester) async {
      when(() => restaurantListProvider.resultState)
          .thenReturn(RestaurantListLoadedState(data: []));
      when(() => localDatabaseProvider.restaurantList).thenReturn([]);
      when(() => localDatabaseProvider.loadAllRestaurants())
          .thenAnswer((_) async => Future<void>.value());

      await tester.pumpWidget(widget);
      await tester.fling(
        find.byType(SingleChildScrollView),
        const Offset(0, 300),
        1000,
      );
      await tester.pumpAndSettle();

      verify(() => restaurantListProvider.fetchRestaurants()).called(1);
      verify(() => localDatabaseProvider.loadAllRestaurants()).called(1);
    });

    testWidgets('should have AppBar with correct title', (tester) async {
      when(() => restaurantListProvider.resultState)
          .thenReturn(RestaurantListLoadedState(data: []));
      when(() => localDatabaseProvider.restaurantList).thenReturn([]);
      when(() => localDatabaseProvider.loadAllRestaurants())
          .thenAnswer((_) async => Future<void>.value());

      await tester.pumpWidget(widget);

      final appBarFinder = find.byType(AppBar);
      expect(appBarFinder, findsOneWidget);

      final titleFinder = find.text('Restaurant App');
      expect(titleFinder, findsOneWidget);
    });
  });
}
