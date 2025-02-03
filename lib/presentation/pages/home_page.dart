import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app/domain/entities/restaurant_list_model.dart';
import 'package:restaurant_app/presentation/providers/restaurant/providers/restaurant_detail_provider.dart';
import 'package:restaurant_app/presentation/providers/restaurant/providers/restaurant_list_provider.dart';
import 'package:restaurant_app/presentation/providers/restaurant/providers/local_database_provider.dart';
import 'package:restaurant_app/presentation/routes/navigation_route.dart';
import 'package:restaurant_app/presentation/providers/restaurant/states/restaurant_list_state.dart';
import 'package:restaurant_app/presentation/themes/typography/app_text_styles.dart';
import 'package:restaurant_app/presentation/widgets/restaurant_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      await context.read<RestaurantListProvider>().fetchRestaurants();
      await context.read<LocalDatabaseProvider>().loadAllRestaurants();
    });
  }

  Future<void> _refreshData() async {
    await context.read<RestaurantListProvider>().fetchRestaurants();
    await context.read<LocalDatabaseProvider>().loadAllRestaurants();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Restaurant App', style: AppTextStyles.titleLarge),
        elevation: 0,
      ),
      body: Consumer2<RestaurantListProvider, LocalDatabaseProvider>(
        builder: (context, restaurantProvider, localDbProvider, child) {
          return switch (restaurantProvider.resultState) {
            RestaurantListLoadingState _ =>
              const Center(child: CircularProgressIndicator()),
            RestaurantListErrorState(message: var error) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Gagal memuat data: $error",
                      style:
                          AppTextStyles.bodyLarge.copyWith(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context
                            .read<RestaurantListProvider>()
                            .fetchRestaurants();
                      },
                      child: const Text("Coba Lagi"),
                    ),
                  ],
                ),
              ),
            RestaurantListLoadedState(data: List<Restaurant> restaurants) =>
              RefreshIndicator(
                onRefresh: _refreshData,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Restaurant",
                          style: AppTextStyles.headlineLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Berikut adalah daftar restoran yang tersedia",
                          style: AppTextStyles.bodyMedium
                              .copyWith(color: Colors.grey),
                        ),
                        const SizedBox(height: 16),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: restaurants.length,
                          itemBuilder: (context, index) {
                            final Restaurant restaurant = restaurants[index];
                            final isFavorite = localDbProvider.restaurantList
                                    ?.any((fav) => fav.id == restaurant.id) ??
                                false;

                            return RestaurantCard(
                              restaurant: restaurant,
                              showFavoriteIcon: true,
                              showDeleteIcon: false,
                              isFavorite: isFavorite,
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  NavigationRoute.detailRoute.name,
                                  arguments: restaurant.id,
                                ).then((_) {
                                  localDbProvider.loadAllRestaurants();
                                });
                              },
                              onDelete: () {
                                if (restaurant.id != null) {
                                  localDbProvider
                                      .removeRestaurant(restaurant.id!);
                                }
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            _ => const SizedBox(),
          };
        },
      ),
    );
  }
}
