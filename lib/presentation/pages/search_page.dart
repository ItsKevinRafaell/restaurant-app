import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app/presentation/providers/restaurant/providers/local_database_provider.dart';
import 'package:restaurant_app/presentation/providers/restaurant/providers/restaurant_search_provider.dart';
import 'package:restaurant_app/presentation/providers/restaurant/states/restaurant_search_state.dart';
import 'package:restaurant_app/presentation/providers/restaurant/providers/restaurant_detail_provider.dart';
import 'package:restaurant_app/presentation/routes/navigation_route.dart';
import 'package:restaurant_app/presentation/themes/typography/app_text_styles.dart';
import 'package:restaurant_app/presentation/widgets/restaurant_card.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    final searchProvider = Provider.of<RestaurantSearchProvider>(context);

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
            TextField(
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
                    final query = searchProvider.searchController.text.trim();
                    if (query.isNotEmpty) {
                      searchProvider.searchRestaurantsByQuery(query);
                    }
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              style: Theme.of(context).textTheme.bodyMedium,
              onSubmitted: (query) {
                if (query.trim().isNotEmpty) {
                  searchProvider.searchRestaurantsByQuery(query.trim());
                }
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Consumer<RestaurantSearchProvider>(
                builder: (context, provider, child) {
                  return switch (provider.resultState) {
                    RestaurantSearchInitialState() => Center(
                        child: Text(
                          'Masukkan kata kunci untuk mencari restoran.',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: Colors.grey),
                        ),
                      ),
                    RestaurantSearchLoadingState() =>
                      const Center(child: CircularProgressIndicator()),
                    RestaurantSearchLoadedState(data: var restaurants) =>
                      restaurants.isEmpty
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
                                final detailProvider =
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
                            ),
                    RestaurantSearchErrorState(message: var error) => Center(
                        child: Text(
                          error,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: Colors.red),
                        ),
                      ),
                    _ => const SizedBox(),
                  };
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
