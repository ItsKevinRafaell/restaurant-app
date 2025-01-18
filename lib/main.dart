import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app/data/api_services.dart';
import 'package:restaurant_app/presentation/pages/detail_page.dart';
import 'package:restaurant_app/presentation/pages/main_page.dart';
import 'package:restaurant_app/presentation/pages/review_page.dart';
import 'package:restaurant_app/presentation/pages/search_page.dart';
import 'package:restaurant_app/presentation/providers/main/index_nav_provider.dart';
import 'package:restaurant_app/presentation/providers/restaurant/restaurant_detail_provider.dart';
import 'package:restaurant_app/presentation/providers/restaurant/restaurant_list_provider.dart';
import 'package:restaurant_app/presentation/providers/restaurant/restaurant_review_provider.dart';
import 'package:restaurant_app/presentation/providers/restaurant/restaurant_search_provider.dart';
import 'package:restaurant_app/presentation/routes/navigation_route.dart';
import 'presentation/themes/app_theme.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => IndexNavProvider(),
        ),
        ChangeNotifierProvider(
            create: (context) => RestaurantListProvider(ApiServices())),
        ChangeNotifierProvider(
            create: (context) => RestaurantDetailProvider(ApiServices())),
        ChangeNotifierProvider(
          create: (context) =>
              RestaurantSearchProvider(ApiServices()), // Tambahkan provider ini
        ),
        ChangeNotifierProvider(
          create: (context) => RestaurantReviewProvider(ApiServices()),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Restaurant App',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      initialRoute: NavigationRoute.mainRoute.name,
      routes: {
        NavigationRoute.mainRoute.name: (context) => const MainPage(),
        NavigationRoute.searchRoute.name: (context) => const SearchPage(),
        NavigationRoute.detailRoute.name: (context) => DetailPage(
              restaurantId:
                  ModalRoute.of(context)?.settings.arguments as String,
            ),
        NavigationRoute.revieWRoute.name: (context) => ReviewPage(
              restaurantId:
                  ModalRoute.of(context)?.settings.arguments as String,
            ),
      },
    );
  }
}
