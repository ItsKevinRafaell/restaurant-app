import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app/presentation/providers/restaurant/providers/local_database_provider.dart';
import 'package:restaurant_app/presentation/providers/restaurant/providers/restaurant_detail_provider.dart';
import 'package:restaurant_app/presentation/providers/restaurant/states/local_database_state.dart';
import 'package:restaurant_app/presentation/routes/navigation_route.dart';
import 'package:restaurant_app/presentation/widgets/restaurant_card.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  Future<void> _refreshData(BuildContext context) async {
    await context.read<LocalDatabaseProvider>().loadAllRestaurants();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Favorite Restaurants"),
      ),
      body: Consumer<LocalDatabaseProvider>(
        builder: (context, provider, child) {
          return RefreshIndicator(
            onRefresh: () => _refreshData(context),
            child: switch (provider.resultState) {
              LocalDatabaseLoadingState _ =>
                const Center(child: CircularProgressIndicator()),
              LocalDatabaseErrorState(message: var error) => Center(
                  child: Text(error),
                ),
              LocalDatabaseLoadedState(data: var restaurants) => Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView.builder(
                    itemCount: restaurants.length,
                    itemBuilder: (context, index) {
                      final restaurant = restaurants[index];
                      return RestaurantCard(
                        restaurant: restaurant.toRestaurant(),
                        isFavorite: true,
                        showFavoriteIcon: false,
                        showDeleteIcon: true,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            NavigationRoute.detailRoute.name,
                            arguments: restaurant.id,
                          ).then((_) {
                            // Reload data when returning to Favorite page
                            provider.loadAllRestaurants();
                          });
                        },
                        onDelete: () {
                          provider.removeRestaurant(restaurant.id!);
                        },
                      );
                    },
                  ),
                ),
              _ => const Center(child: Text("No data available")),
            },
          );
        },
      ),
    );
  }
}
