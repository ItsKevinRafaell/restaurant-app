import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app/domain/entities/received_notification.dart';
import 'package:restaurant_app/data/services/local_notification_service.dart';
import 'package:restaurant_app/presentation/pages/favorite_page.dart';
import 'package:restaurant_app/presentation/pages/home_page.dart';
import 'package:restaurant_app/presentation/pages/search_page.dart';
import 'package:restaurant_app/presentation/pages/setting_page.dart';
import 'package:restaurant_app/presentation/providers/navigation/index_nav_provider.dart';
import 'package:restaurant_app/presentation/providers/navigation/payload_provider.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  void _configureDidReceiveLocalNotificationSubject() {
    didReceiveLocalNotificationStream.stream
        .listen((ReceivedNotification receivedNotification) {
      if (receivedNotification.payload != null) {
        context.read<PayloadProvider>().updatePayload(receivedNotification.payload!);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _configureDidReceiveLocalNotificationSubject();
  }

  @override
  void dispose() {
    didReceiveLocalNotificationStream.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<IndexNavProvider>(
        builder: (_, provider, __) {
          return switch (provider.currentIndex) {
            1 => const SearchPage(),
            2 => const FavoritePage(),
            3 => const SettingPage(),
            _ => const HomePage(),
          };
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Theme.of(context).primaryColor,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        currentIndex: context.watch<IndexNavProvider>().currentIndex,
        onTap: (index) {
          context.read<IndexNavProvider>().updateIndex(index);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
            tooltip: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: "Search",
            tooltip: "Search",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: "Favorite",
            tooltip: "Favorite",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Setting",
            tooltip: "Setting",
          ),
        ],
      ),
    );
  }
}
