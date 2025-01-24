import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app/presentation/providers/restaurant/restaurant_detail_provider.dart';
import 'package:restaurant_app/presentation/providers/restaurant/restaurant_search_provider.dart';
import 'package:restaurant_app/presentation/providers/restaurant/static/restaurant_search_result_state.dart';
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
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: searchProvider.searchController,
              decoration: InputDecoration(
                hintText: 'Cari restoran...',
                hintStyle:
                    AppTextStyles.bodyMedium.copyWith(color: Colors.grey),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    final query = searchProvider.searchController.text.trim();
                    if (query.isNotEmpty) {
                      searchProvider.searchRestaurants(query);
                    }
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              style: AppTextStyles.bodyMedium,
              onSubmitted: (query) {
                if (query.isNotEmpty) {
                  searchProvider.searchRestaurants(query);
                }
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Consumer<RestaurantSearchProvider>(
                builder: (context, provider, child) {
                  return switch (provider.resultState) {
                    RestaurantSearchNoneState() => Center(
                        child: Text(
                          'Masukkan kata kunci untuk mencari restoran.',
                          style: AppTextStyles.bodyMedium
                              .copyWith(color: Colors.grey),
                        ),
                      ),
                    RestaurantSearchLoadingState _ =>
                      const Center(child: CircularProgressIndicator()),
                    RestaurantSearchLoadedState(restaurants: var restaurants) =>
                      restaurants.isEmpty
                          ? Center(
                              child: Text(
                                'Tidak ada restoran yang ditemukan.',
                                style: AppTextStyles.bodyMedium
                                    .copyWith(color: Colors.grey),
                              ),
                            )
                          : ListView.builder(
                              itemCount: restaurants.length,
                              itemBuilder: (context, index) {
                                final restaurant = restaurants[index];
                                return RestaurantCard(
                                  restaurant: restaurant,
                                  onTap: () {
                                    context
                                        .read<RestaurantDetailProvider>()
                                        .setRestaurantImage(
                                          'https://restaurant-api.dicoding.dev/images/small/${restaurant.pictureId}',
                                        );
                                    Navigator.pushNamed(
                                      context,
                                      '/detail',
                                      arguments: restaurant.id,
                                    );
                                  },
                                );
                              },
                            ),
                    RestaurantSearchErrorState(error: var error) => Center(
                        child: Text(
                          error,
                          style: AppTextStyles.bodyMedium
                              .copyWith(color: Colors.red),
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
