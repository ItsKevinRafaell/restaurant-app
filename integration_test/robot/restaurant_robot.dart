import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class RestaurantRobot {
  final WidgetTester tester;

  const RestaurantRobot(this.tester);

  // Key definitions
  final searchFieldKey = const ValueKey("searchField");
  final restaurantListKey = const ValueKey("restaurantList");
  final retryButtonKey = const ValueKey("retryButton");
  final loadingIndicatorKey = const ValueKey("loadingIndicator");
  final errorMessageKey = const ValueKey("errorMessage");

  Future<void> loadUI(Widget widget) async {
    await tester.pumpWidget(widget);
    // Wait for any animations to complete
    await tester.pumpAndSettle();
  }

  Future<void> scrollRestaurantList() async {
    final listFinder = find.byKey(restaurantListKey);
    await tester.fling(listFinder, const Offset(0, -500), 10000);
    await tester.pumpAndSettle();
  }

  Future<void> tapRetryButton() async {
    final retryButtonFinder = find.byKey(retryButtonKey);
    await tester.tap(retryButtonFinder);
    await tester.pumpAndSettle();
  }

  Future<void> searchRestaurant(String query) async {
    final searchFieldFinder = find.byKey(searchFieldKey);
    await tester.tap(searchFieldFinder);
    await tester.enterText(searchFieldFinder, query);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
  }

  Future<void> verifyLoadingIndicator() async {
    expect(find.byKey(loadingIndicatorKey), findsOneWidget);
  }

  Future<void> verifyErrorMessage(String message) async {
    final errorFinder = find.byKey(errorMessageKey);
    final errorWidget = tester.widget<Text>(errorFinder);
    expect(errorWidget.data, contains(message));
  }

  Future<void> verifyRestaurantExists(String restaurantName) async {
    expect(find.text(restaurantName), findsOneWidget);
  }

  Future<void> tapRestaurant(String restaurantName) async {
    await tester.tap(find.text(restaurantName));
    await tester.pumpAndSettle();
  }

  Future<void> verifyRestaurantDetail(String restaurantName) async {
    expect(find.text(restaurantName), findsOneWidget);
    // Verify other detail elements as needed
  }
}
