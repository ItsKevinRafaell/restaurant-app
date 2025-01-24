import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app/presentation/providers/restaurant/restaurant_detail_provider.dart';
import 'package:restaurant_app/presentation/providers/restaurant/restaurant_list_provider.dart';
import 'package:restaurant_app/presentation/routes/navigation_route.dart';
import 'package:restaurant_app/presentation/providers/restaurant/static/restaurant_list_result_state.dart';
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

    Future.microtask(() {
      context.read<RestaurantListProvider>().fetchRestaurants();
    });
  }

  Future<void> _refreshData() async {
    await context.read<RestaurantListProvider>().fetchRestaurants();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Restaurant App', style: AppTextStyles.titleLarge),
        elevation: 0,
      ),
      body: Consumer<RestaurantListProvider>(
        builder: (context, provider, child) {
          return switch (provider.resultState) {
            RestaurantListLoadingState _ =>
              const Center(child: CircularProgressIndicator()),
            RestaurantListErrorState(error: var error) => Center(
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
            RestaurantListLoadedState(data: var restaurants) =>
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
                                    context, NavigationRoute.detailRoute.name,
                                    arguments: restaurant.id);
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
