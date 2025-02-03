import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class RestaurantRobot {
  final WidgetTester tester;

  const RestaurantRobot(this.tester);

  final searchFieldKey = const ValueKey("searchField");
  final restaurantListKey = const ValueKey("restaurantList");
  final retryButtonKey = const ValueKey("retryButton");
  final loadingIndicatorKey = const ValueKey("loadingIndicator");
  final errorMessageKey = const ValueKey("errorMessage");

  Future<void> loadUI(Widget widget) async {
    await tester.pumpWidget(widget);

    await tester.pumpAndSettle();
  }

  Future<void> scrollRestaurantList() async {
    final listFinder = find.byKey(restaurantListKey);
    await tester.fling(listFinder, const Offset(0, -500), 10000);
    await tester.pumpAndSettle();
  }

  Future<void> verifyErrorMessage(String message) async {
    final errorFinder = find.byKey(errorMessageKey);
    final errorWidget = tester.widget<Text>(errorFinder);
    expect(
      errorWidget.data,
      contains(message),
    );
  }

  Future<void> verifyRestaurantExists(String restaurantName) async {
    expect(find.text(restaurantName), findsOneWidget);
  }

  Future<void> tapRestaurant(String restaurantName) async {
    await tester.tap(
      find.text(restaurantName),
    );
    await tester.pumpAndSettle();
  }

  Future<void> verifyRestaurantDetail(String restaurantName) async {
    expect(find.text(restaurantName), findsOneWidget);
  }
}
