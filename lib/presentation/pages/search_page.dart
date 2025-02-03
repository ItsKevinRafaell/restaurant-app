import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app/presentation/providers/restaurant/providers/local_database_provider.dart';
import 'package:restaurant_app/presentation/providers/restaurant/providers/restaurant_search_provider.dart';
import 'package:restaurant_app/presentation/providers/restaurant/states/restaurant_search_result_state.dart';
import 'package:restaurant_app/presentation/providers/restaurant/providers/restaurant_detail_provider.dart';
import 'package:restaurant_app/presentation/routes/navigation_route.dart';
import 'package:restaurant_app/presentation/themes/typography/app_text_styles.dart';
import 'package:restaurant_app/presentation/widgets/restaurant_card.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  void _searchRestaurants(BuildContext context, String query) {
    if (query.isNotEmpty) {
      context.read<RestaurantSearchProvider>().searchRestaurantsByQuery(query);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Restaurant App', style: AppTextStyles.titleLarge),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Cari Restaurant",
              style: AppTextStyles.headlineLarge,
            ),
            const SizedBox(height: 8),
            Text(
              "Mari temukan restoran favoritmu!",
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Consumer<RestaurantSearchProvider>(
              builder: (context, searchProvider, child) {
                return TextField(
                  controller: searchProvider.searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari restoran...',
                    hintStyle: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Colors.grey),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () {
                        _searchRestaurants(
                          context,
                          searchProvider.searchController.text.trim(),
                        );
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  style: Theme.of(context).textTheme.bodyMedium,
                  onSubmitted: (query) {
                    _searchRestaurants(
                      context,
                      query.trim(),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Consumer<RestaurantSearchProvider>(
                builder: (context, provider, child) {
                  switch (provider.resultState) {
                    case RestaurantSearchInitialState():
                      return Center(
                        child: Text(
                          'Masukkan kata kunci untuk mencari restoran.',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: Colors.grey),
                        ),
                      );
                    case RestaurantSearchLoadingState():
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    case RestaurantSearchLoadedState(data: var restaurants):
                      return restaurants.isEmpty
                          ? Center(
                              child: Text(
                                'Tidak ada restoran yang ditemukan.',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: Colors.grey),
                              ),
                            )
                          : ListView.builder(
                              itemCount: restaurants.length,
                              itemBuilder: (context, index) {
                                final restaurant = restaurants[index];

                                context.watch<RestaurantDetailProvider>();
                                final localDbProvider =
                                    context.watch<LocalDatabaseProvider>();

                                return FutureBuilder<bool>(
                                  future: localDbProvider
                                      .isRestaurantExist(restaurant.id ?? ''),
                                  builder: (context, snapshot) {
                                    final isFavorite = snapshot.data ?? false;

                                    return RestaurantCard(
                                      restaurant: restaurant,
                                      isFavorite: isFavorite,
                                      onTap: () {
                                        context
                                            .read<RestaurantDetailProvider>()
                                            .setRestaurantImage(
                                                restaurant.pictureId!);
                                        Navigator.pushNamed(
                                          context,
                                          NavigationRoute.detailRoute.name,
                                          arguments: restaurant.id,
                                        );
                                      },
                                      showFavoriteIcon: true,
                                      onFavoriteToggle: null,
                                    );
                                  },
                                );
                              },
                            );
                    case RestaurantSearchErrorState(message: var error):
                      return Center(
                        child: Text(
                          error,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: Colors.red),
                        ),
                      );
                    default:
                      return const SizedBox();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
