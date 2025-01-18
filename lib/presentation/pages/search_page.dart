import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app/presentation/providers/restaurant/restaurant_search_provider.dart';
import 'package:restaurant_app/presentation/providers/restaurant/restaurant_search_result_state.dart';
import 'package:restaurant_app/presentation/widgets/restaurant_card.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  @override
  Widget build(BuildContext context) {
    final searchProvider = Provider.of<RestaurantSearchProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurant App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Cari Restaurant",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Mari temukan restoran favoritmu!",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: searchProvider.searchController,
              decoration: InputDecoration(
                hintText: 'Cari restoran...',
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
                    RestaurantSearchNoneState() => const Center(
                        child:
                            Text('Masukkan kata kunci untuk mencari restoran.'),
                      ),
                    RestaurantSearchLoadingState() => const Center(
                        child: CircularProgressIndicator(),
                      ),
                    RestaurantSearchLoadedState(restaurants: var restaurants) =>
                      restaurants.isEmpty
                          ? const Center(
                              child: Text(
                                'Tidak ada restoran yang ditemukan.',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            )
                          : ListView.builder(
                              itemCount: restaurants.length,
                              itemBuilder: (context, index) {
                                final restaurant = restaurants[index];
                                return RestaurantCard(
                                  restaurant: restaurant,
                                  onTap: () {
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
                          style: const TextStyle(color: Colors.red),
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
