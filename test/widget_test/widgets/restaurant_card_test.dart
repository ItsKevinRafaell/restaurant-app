import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_app/domain/entities/restaurant_list_model.dart';
import 'package:restaurant_app/presentation/widgets/restaurant_card.dart';

void main() {
  late Restaurant mockRestaurant;
  late Widget testWidget;
  bool wasClicked = false;
  bool wasDeleted = false;

  setUp(() {
    wasClicked = false;
    wasDeleted = false;
    mockRestaurant = Restaurant(
      id: '1',
      name: 'Test Restaurant',
      description: 'Test Description',
      pictureId: 'test_picture.jpg',
      city: 'Test City',
      rating: 4.5,
    );

    testWidget = MaterialApp(
      home: Scaffold(
        body: RestaurantCard(
          restaurant: mockRestaurant,
          onTap: () => wasClicked = true,
          onDelete: () => wasDeleted = true,
          isFavorite: true,
          showFavoriteIcon: true,
          showDeleteIcon: true,
        ),
      ),
    );
  });

  group('RestaurantCard Widget Test', () {
    testWidgets('should display restaurant information correctly',
        (tester) async {
      await tester.pumpWidget(testWidget);

      expect(find.text('Test Restaurant'), findsOneWidget);
      expect(find.text('Test City'), findsOneWidget);
      expect(find.text('Test Description'), findsOneWidget);
      expect(find.text('4.5'), findsOneWidget);
    });

    testWidgets('should handle null values gracefully', (tester) async {
      final nullRestaurant = Restaurant(
        id: '1',
        name: null,
        description: null,
        pictureId: null,
        city: null,
        rating: null,
      );

      final nullWidget = MaterialApp(
        home: Scaffold(
          body: RestaurantCard(
            restaurant: nullRestaurant,
            onTap: () {},
          ),
        ),
      );

      await tester.pumpWidget(nullWidget);

      expect(find.text('No name available'), findsOneWidget);
      expect(find.text('No city available'), findsOneWidget);
      expect(find.text('No description available'), findsOneWidget);
      expect(find.text('0.0'), findsOneWidget);
    });

    testWidgets('should show favorite icon when specified', (tester) async {
      await tester.pumpWidget(testWidget);

      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });

    testWidgets('should hide favorite icon when specified', (tester) async {
      final widget = MaterialApp(
        home: Scaffold(
          body: RestaurantCard(
            restaurant: mockRestaurant,
            onTap: () {},
            showFavoriteIcon: false,
          ),
        ),
      );

      await tester.pumpWidget(widget);

      expect(find.byIcon(Icons.favorite), findsNothing);
    });

    testWidgets('should show delete icon when specified', (tester) async {
      await tester.pumpWidget(testWidget);

      expect(find.byIcon(Icons.delete), findsOneWidget);
    });

    testWidgets('should trigger onTap callback when tapped', (tester) async {
      await tester.pumpWidget(testWidget);

      await tester.tap(find.byType(GestureDetector));
      await tester.pump();

      expect(wasClicked, true);
    });

    testWidgets('should trigger onDelete callback when delete button pressed',
        (tester) async {
      await tester.pumpWidget(testWidget);

      await tester.tap(find.byIcon(Icons.delete));
      await tester.pump();

      expect(wasDeleted, true);
    });

    testWidgets('should display network image correctly', (tester) async {
      await tester.pumpWidget(testWidget);

      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Image &&
              widget.image is NetworkImage &&
              (widget.image as NetworkImage)
                  .url
                  .contains('test_picture.jpg'),
        ),
        findsOneWidget,
      );
    });
  });
}
