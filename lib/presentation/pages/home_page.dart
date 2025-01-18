import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app/presentation/providers/restaurant/restaurant_list_provider.dart';
import 'package:restaurant_app/presentation/routes/navigation_route.dart';
import 'package:restaurant_app/presentation/providers/restaurant/restaurant_list_result_state.dart';
import 'package:restaurant_app/presentation/widgets/restaurant_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<RestaurantListProvider>().fetchRestaurants();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurant App'),
        elevation: 0,
      ),
      body: Consumer<RestaurantListProvider>(
        builder: (context, provider, child) {
          return switch (provider.resultState) {
            RestaurantListLoadingState =>
              const Center(child: CircularProgressIndicator()),
            RestaurantListErrorState(error: var error) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Gambar atau ikon error
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    // Pesan error
                    Text(
                      "Gagal memuat data: $error",
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.red,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    // Tombol untuk mencoba lagi
                    ElevatedButton(
                      onPressed: () {
                        // Memuat ulang data
                        context
                            .read<RestaurantListProvider>()
                            .fetchRestaurants();
                      },
                      child: const Text("Coba Lagi"),
                    ),
                  ],
                ),
              ),
            RestaurantListLoadedState(data: var restaurants) =>
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Restaurant",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Berikut adalah daftar restoran yang tersedia",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: restaurants.length,
                        itemBuilder: (context, index) {
                          final restaurant = restaurants[index];
                          return RestaurantCard(
                            restaurant: restaurant,
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                NavigationRoute.detailRoute.name,
                                arguments: restaurant.id,
                              );
                            },
                          );
                        },
                      ),
                    ],
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
