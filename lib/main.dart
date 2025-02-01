import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app/data/datasources/remote/api_services.dart';
import 'package:restaurant_app/data/datasources/local/local_database_service.dart';
import 'package:restaurant_app/data/repositories/restaurant_repository_impl.dart';
import 'package:restaurant_app/data/services/local_notification_service.dart';
import 'package:restaurant_app/data/services/workmanager_service.dart';
import 'package:restaurant_app/presentation/pages/detail_page.dart';
import 'package:restaurant_app/presentation/pages/favorite_page.dart';
import 'package:restaurant_app/presentation/pages/main_page.dart';
import 'package:restaurant_app/presentation/pages/review_page.dart';
import 'package:restaurant_app/presentation/pages/search_page.dart';
import 'package:restaurant_app/presentation/pages/setting_page.dart';
import 'package:restaurant_app/presentation/providers/notification/local_notification_provider.dart';
import 'package:restaurant_app/presentation/providers/navigation/index_nav_provider.dart';
import 'package:restaurant_app/presentation/providers/navigation/payload_provider.dart';
import 'package:restaurant_app/presentation/providers/restaurant/providers/local_database_provider.dart';
import 'package:restaurant_app/presentation/providers/restaurant/providers/restaurant_list_provider.dart';
import 'package:restaurant_app/presentation/providers/restaurant/providers/restaurant_search_provider.dart';
import 'package:restaurant_app/presentation/providers/restaurant/providers/restaurant_detail_provider.dart';
import 'package:restaurant_app/presentation/providers/restaurant/providers/restaurant_review_provider.dart';
import 'package:restaurant_app/presentation/providers/restaurant/providers/favorite_provider.dart';
import 'package:restaurant_app/presentation/routes/navigation_route.dart';
import 'package:restaurant_app/presentation/themes/theme_provider.dart';
import 'package:workmanager/workmanager.dart';
import 'presentation/themes/app_theme.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final localNotificationService = LocalNotificationService();
  await localNotificationService.init();
  await localNotificationService.configureLocalTimeZone();
  await localNotificationService.requestPermissions();

  // Initialize Workmanager at app startup
  await WorkmanagerService.initializeWorkmanager();
  debugPrint('Main: Workmanager initialized and scheduled for 11 AM');

  final notificationAppLaunchDetails =
      await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  String? payload;

  if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
    final notificationResponse =
        notificationAppLaunchDetails!.notificationResponse;
    payload = notificationResponse?.payload;
    if (payload != null && payload.isNotEmpty) {
      debugPrint('Main: App launched from notification with payload: $payload');
      // Delay navigation to ensure app is fully initialized
      Future.delayed(const Duration(milliseconds: 100), () {
        navigatorKey.currentState?.pushNamed(
          NavigationRoute.detailRoute.name,
          arguments: payload,
        );
      });
    }
  }

  // Listen for notification selection
  selectNotificationStream.stream.listen((String? payload) {
    if (payload != null && payload.isNotEmpty) {
      debugPrint('Main: Notification selected with payload: $payload');
      navigatorKey.currentState?.pushNamed(
        NavigationRoute.detailRoute.name,
        arguments: payload,
      );
    }
  });

  runApp(
    MultiProvider(
      providers: [
        Provider(
          create: (context) {
            WorkmanagerService.initializeWorkmanager();
            final workmanagerService = WorkmanagerService();
            workmanagerService.runPeriodicTask();
            return workmanagerService;
          },
        ),
        ChangeNotifierProvider(
          create: (context) =>
              LocalNotificationProvider(localNotificationService),
        ),
        ChangeNotifierProvider(
          create: (context) => PayloadProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => IndexNavProvider(),
        ),
        ChangeNotifierProvider(
            create: (context) => RestaurantListProvider(ApiServices())),
        ChangeNotifierProvider(
          create: (context) => LocalDatabaseProvider(LocalDatabaseService()),
        ),
        ChangeNotifierProxyProvider<LocalDatabaseProvider, FavoriteProvider>(
          create: (context) => FavoriteProvider(
            localDatabaseProvider: context.read<LocalDatabaseProvider>(),
          ),
          update: (context, localDatabaseProvider, previousFavoriteProvider) =>
              previousFavoriteProvider ?? FavoriteProvider(
                localDatabaseProvider: localDatabaseProvider,
              ),
        ),
        ChangeNotifierProvider(
          create: (context) => RestaurantDetailProvider(
            repository: RestaurantRepositoryImpl(
              ApiServices(),
              LocalDatabaseService(),
            ),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => RestaurantSearchProvider(ApiServices()),
        ),
        ChangeNotifierProvider(
          create: (context) => RestaurantReviewProvider(
            apiService: ApiServices(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => ThemeProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(builder: (context, provider, _) {
      return MaterialApp(
        navigatorKey: navigatorKey,
        title: 'Restaurant App',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: provider.themeMode,
        debugShowCheckedModeBanner: false,
        initialRoute: NavigationRoute.mainRoute.name,
        routes: {
          NavigationRoute.mainRoute.name: (context) => const MainPage(),
          NavigationRoute.searchRoute.name: (context) => const SearchPage(),
          NavigationRoute.detailRoute.name: (context) => DetailPage(
                restaurantId:
                    ModalRoute.of(context)?.settings.arguments as String,
              ),
          NavigationRoute.reviewRoute.name: (context) => ReviewPage(
                restaurantId:
                    ModalRoute.of(context)?.settings.arguments as String,
              ),
          NavigationRoute.settingRoute.name: (context) => const SettingPage(),
          NavigationRoute.favoriteRoute.name: (context) => const FavoritePage(),
        },
      );
    });
  }
}
