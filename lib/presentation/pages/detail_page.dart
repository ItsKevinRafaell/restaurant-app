import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app/presentation/providers/restaurant/restaurant_detail_provider.dart';
import 'package:restaurant_app/presentation/providers/restaurant/restaurant_detail_result_state.dart';
import 'package:restaurant_app/presentation/widgets/menu_item_card.dart';

class DetailPage extends StatefulWidget {
  final String restaurantId;

  const DetailPage({Key? key, required this.restaurantId}) : super(key: key);

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  bool isDescriptionExpanded = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context
          .read<RestaurantDetailProvider>()
          .fetchRestaurantDetail(widget.restaurantId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurant Detail'),
        elevation: 0,
      ),
      body: Consumer<RestaurantDetailProvider>(
        builder: (context, provider, child) {
          return switch (provider.resultState) {
            RestaurantDetailLoadingState =>
              const Center(child: CircularProgressIndicator()),
            RestaurantDetailLoadedState(data: var restaurant) =>
              CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        'https://restaurant-api.dicoding.dev/images/large/${restaurant.restaurant!.pictureId}',
                        width: double.infinity,
                        height: 250,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SliverPadding(
                      padding: EdgeInsets.symmetric(vertical: 16.0)),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        restaurant.restaurant!.name!,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on,
                              size: 18, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            restaurant.restaurant!.city!,
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(width: 16),
                          const Icon(Icons.star, size: 18, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            "${restaurant.restaurant!.rating}",
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SliverPadding(
                      padding: EdgeInsets.symmetric(vertical: 16.0)),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            restaurant.restaurant!.description!,
                            maxLines: isDescriptionExpanded ? null : 3,
                            overflow: isDescriptionExpanded
                                ? TextOverflow.visible
                                : TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              height: 1.5,
                              color: Colors.grey,
                            ),
                          ),
                          if (restaurant.restaurant!.description!.length >
                              100) // Hanya tampilkan tombol jika deskripsi panjang
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  isDescriptionExpanded =
                                      !isDescriptionExpanded; // Toggle state
                                });
                              },
                              child: Text(
                                isDescriptionExpanded
                                    ? 'Sembunyikan'
                                    : 'Selengkapnya', // Tentukan teks tombol
                                style: const TextStyle(
                                  color: Colors.blue, // Warna teks tombol
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              "Ulasan Pelanggan",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                '/review',
                                arguments: widget.restaurantId,
                              );
                            },
                            icon: const Icon(Icons.add),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SliverPadding(
                      padding: EdgeInsets.symmetric(vertical: 8.0)),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    sliver: SliverToBoxAdapter(
                      child: SizedBox(
                        height: 150, // Tinggi container untuk grid horizontal
                        child: GridView.builder(
                          scrollDirection: Axis.horizontal, // Scroll horizontal
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 1, // Satu baris
                            mainAxisSpacing: 16, // Spasi antar item
                            crossAxisSpacing: 16, // Spasi antar item
                            childAspectRatio: 1, // Rasio lebar/tinggi item
                          ),
                          itemCount:
                              restaurant.restaurant!.customerReviews!.length,
                          itemBuilder: (context, index) {
                            final review =
                                restaurant.restaurant!.customerReviews![index];
                            return Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      review.name!,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Expanded(
                                      child: Text(
                                        review.review!,
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      review.date!,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  const SliverPadding(
                      padding: EdgeInsets.symmetric(vertical: 16.0)),
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        "Menu Makanan",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SliverPadding(
                      padding: EdgeInsets.symmetric(vertical: 8.0)),
                  SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.4,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final food =
                            restaurant.restaurant!.menus!.foods![index];
                        return MenuItemCard(
                          itemName: food.name!,
                          imageUrl:
                              'https://restaurant-api.dicoding.dev/images/large/${restaurant.restaurant!.pictureId}',
                        );
                      },
                      childCount: restaurant.restaurant!.menus!.foods!.length,
                    ),
                  ),
                  const SliverPadding(
                      padding: EdgeInsets.symmetric(vertical: 16.0)),
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        "Menu Minuman",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SliverPadding(
                      padding: EdgeInsets.symmetric(vertical: 8.0)),
                  SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.4,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final drink =
                            restaurant.restaurant!.menus!.drinks![index];
                        return MenuItemCard(
                          itemName: drink.name!,
                          imageUrl:
                              'https://restaurant-api.dicoding.dev/images/large/${restaurant.restaurant!.pictureId}',
                        );
                      },
                      childCount: restaurant.restaurant!.menus!.drinks!.length,
                    ),
                  ),
                  const SliverPadding(
                      padding: EdgeInsets.symmetric(vertical: 16.0)),
                ],
              ),
            RestaurantDetailErrorState(error: var error) => Center(
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
                            .read<RestaurantDetailProvider>()
                            .fetchRestaurantDetail(widget.restaurantId);
                      },
                      child: const Text("Coba Lagi"),
                    ),
                  ],
                ),
              ),
            _ => const SizedBox(),
          };
        },
      ),
    );
  }
}
