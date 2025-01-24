import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app/presentation/providers/restaurant/restaurant_detail_provider.dart';
import 'package:restaurant_app/presentation/providers/restaurant/static/restaurant_detail_result_state.dart';
import 'package:restaurant_app/presentation/themes/typography/app_text_styles.dart';
import 'package:restaurant_app/presentation/widgets/menu_item_card.dart';

class DetailPage extends StatefulWidget {
  final String restaurantId;

  const DetailPage({super.key, required this.restaurantId});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
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
        title: Text('Restaurant Detail', style: AppTextStyles.titleLarge),
        elevation: 0,
      ),
      body: Consumer<RestaurantDetailProvider>(
        builder: (context, provider, child) {
          return switch (provider.resultState) {
            RestaurantDetailLoadingState _ => Column(
                children: [
                  Hero(
                    tag: provider.imageUrl!,
                    child: Image.network(
                      provider.imageUrl!,
                      width: double.infinity,
                      height: 250,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const CircularProgressIndicator(),
                ],
              ),
            RestaurantDetailLoadedState(data: var restaurant) =>
              CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Hero(
                        tag: restaurant.restaurant!.pictureId!,
                        child: Image.network(
                          'https://restaurant-api.dicoding.dev/images/large/${restaurant.restaurant!.pictureId}',
                          width: double.infinity,
                          height: 250,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SliverPadding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        restaurant.restaurant!.name!,
                        style: AppTextStyles.headlineLarge,
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
                            style: AppTextStyles.bodyMedium
                                .copyWith(color: Colors.grey),
                          ),
                          const SizedBox(width: 16),
                          const Icon(Icons.star, size: 18, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            "${restaurant.restaurant!.rating}",
                            style: AppTextStyles.bodyMedium
                                .copyWith(color: Colors.grey),
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
                          const Icon(Icons.location_city,
                              size: 18, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            restaurant.restaurant!.address!,
                            style: AppTextStyles.bodyMedium
                                .copyWith(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Wrap(
                        spacing: 8,
                        children: restaurant.restaurant!.categories!
                            .map((category) => Chip(
                                  label: Text(
                                    category.name!,
                                    style: AppTextStyles.bodyMedium,
                                  ),
                                  backgroundColor: Colors.blue.withOpacity(0.1),
                                ))
                            .toList(),
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
                          Consumer<RestaurantDetailProvider>(
                            builder: (context, provider, child) {
                              return Text(
                                restaurant.restaurant!.description!,
                                maxLines:
                                    provider.isDescriptionExpanded ? null : 3,
                                overflow: provider.isDescriptionExpanded
                                    ? TextOverflow.visible
                                    : TextOverflow.ellipsis,
                                style: AppTextStyles.bodyLarge
                                    .copyWith(color: Colors.grey),
                              );
                            },
                          ),
                          if (restaurant.restaurant!.description!.length > 100)
                            Consumer<RestaurantDetailProvider>(
                              builder: (context, provider, child) {
                                return TextButton(
                                  onPressed: () {
                                    provider.toggleDescriptionExpanded();
                                  },
                                  child: Text(
                                    provider.isDescriptionExpanded
                                        ? 'Sembunyikan'
                                        : 'Selengkapnya',
                                    style: AppTextStyles.labelLarge
                                        .copyWith(color: Colors.blue),
                                  ),
                                );
                              },
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
                          Expanded(
                            child: Text(
                              "Ulasan Pelanggan",
                              style: AppTextStyles.titleLarge,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                '/review',
                                arguments: widget.restaurantId,
                              ).then((_) {
                                context
                                    .read<RestaurantDetailProvider>()
                                    .fetchRestaurantDetail(widget.restaurantId);
                              });
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
                        height: 150,
                        child: GridView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 1,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 1,
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
                                      style: AppTextStyles.titleMedium,
                                    ),
                                    const SizedBox(height: 8),
                                    Expanded(
                                      child: Text(
                                        review.review!,
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTextStyles.bodyMedium
                                            .copyWith(color: Colors.grey),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      review.date!,
                                      style: AppTextStyles.labelSmall
                                          .copyWith(color: Colors.grey),
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
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        "Menu Makanan",
                        style: AppTextStyles.titleLarge,
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
                      childAspectRatio: 1.1,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final food =
                            restaurant.restaurant!.menus!.foods![index];
                        return MenuItemCard(
                          itemName: food.name!,
                          imageUrl:
                              'https://media02.stockfood.com/largepreviews/NDI0NTM5NzYx/13694831-Puff-pastry-salmon-snails-on-a-spinach-salad-for-Christmas.jpg',
                        );
                      },
                      childCount: restaurant.restaurant!.menus!.foods!.length,
                    ),
                  ),
                  const SliverPadding(
                      padding: EdgeInsets.symmetric(vertical: 16.0)),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        "Menu Minuman",
                        style: AppTextStyles.titleLarge,
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
                      childAspectRatio: 1.2,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final drink =
                            restaurant.restaurant!.menus!.drinks![index];
                        return MenuItemCard(
                          itemName: drink.name!,
                          imageUrl:
                              'https://media02.stockfood.com/largepreviews/NDIyNzMwOTEx/13636481-Melon-mojito-horchata-sweet-cinnamon-milk-drink-for-the-Tex-Mex-party.jpg',
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
