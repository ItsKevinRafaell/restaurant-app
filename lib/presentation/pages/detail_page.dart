import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app/presentation/providers/restaurant/providers/restaurant_detail_provider.dart';
import 'package:restaurant_app/presentation/providers/restaurant/providers/favorite_provider.dart';
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
      final detailProvider = context.read<RestaurantDetailProvider>();
      final favoriteProvider = context.read<FavoriteProvider>();

      detailProvider.fetchRestaurantDetail(widget.restaurantId);
      favoriteProvider.checkFavoriteStatus(widget.restaurantId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Restaurant Detail', style: AppTextStyles.titleLarge),
        elevation: 0,
      ),
      body: Consumer2<RestaurantDetailProvider, FavoriteProvider>(
        builder: (context, detailProvider, favoriteProvider, child) {
          if (detailProvider.state == RestaurantDetailState.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (detailProvider.state == RestaurantDetailState.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    "Gagal memuat data: ${detailProvider.message}",
                    style: AppTextStyles.bodyLarge.copyWith(color: Colors.red),
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
            );
          }

          if (detailProvider.restaurant == null) {
            return const SizedBox();
          }

          final restaurant = detailProvider.restaurant!;

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Hero(
                    tag: restaurant.id!,
                    child: Image.network(
                      'https://restaurant-api.dicoding.dev/images/small/${restaurant.pictureId}',
                      width: double.infinity,
                      height: 250,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: double.infinity,
                          height: 250,
                          color: Colors.grey[300],
                          child: const Icon(Icons.error),
                        );
                      },
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          restaurant.name!,
                          style: AppTextStyles.headlineLarge,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          favoriteProvider.isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color:
                              favoriteProvider.isFavorite ? Colors.red : null,
                        ),
                        onPressed: () {
                          favoriteProvider.toggleFavorite(restaurant);
                          debugPrint('click');
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
                      const Icon(Icons.location_on,
                          size: 18, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        restaurant.city!,
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: Colors.grey),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.star, size: 18, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        "${restaurant.rating}",
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
                        restaurant.address!,
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
                    children: restaurant.categories!
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
                      Text(
                        'Description',
                        style: AppTextStyles.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Consumer<RestaurantDetailProvider>(
                        builder: (context, provider, child) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                restaurant.description!,
                                maxLines:
                                    provider.isDescriptionExpanded ? null : 3,
                                overflow: TextOverflow.fade,
                                style: AppTextStyles.bodyMedium,
                              ),
                              const SizedBox(height: 8),
                              Center(
                                child: ElevatedButton(
                                  onPressed: () {
                                    provider.toggleDescription();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor:
                                        Theme.of(context).primaryColor,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24, vertical: 8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        provider.isDescriptionExpanded
                                            ? 'Show Less'
                                            : 'Read More',
                                        style:
                                            AppTextStyles.labelLarge.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(
                                        provider.isDescriptionExpanded
                                            ? Icons.keyboard_arrow_up
                                            : Icons.keyboard_arrow_down,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
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
              const SliverPadding(padding: EdgeInsets.symmetric(vertical: 8.0)),
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
                      itemCount: restaurant.customerReviews!.length,
                      itemBuilder: (context, index) {
                        final review = restaurant.customerReviews![index];
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
              const SliverPadding(padding: EdgeInsets.symmetric(vertical: 8.0)),
              SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.1,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final food = restaurant.menus!.foods![index];
                    return MenuItemCard(
                      itemName: food.name!,
                      imageUrl:
                          'https://media02.stockfood.com/largepreviews/NDI0NTM5NzYx/13694831-Puff-pastry-salmon-snails-on-a-spinach-salad-for-Christmas.jpg',
                    );
                  },
                  childCount: restaurant.menus!.foods!.length,
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
              const SliverPadding(padding: EdgeInsets.symmetric(vertical: 8.0)),
              SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.2,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final drink = restaurant.menus!.drinks![index];
                    return MenuItemCard(
                      itemName: drink.name!,
                      imageUrl:
                          'https://media02.stockfood.com/largepreviews/NDIyNzMwOTEx/13636481-Melon-mojito-horchata-sweet-cinnamon-milk-drink-for-the-Tex-Mex-party.jpg',
                    );
                  },
                  childCount: restaurant.menus!.drinks!.length,
                ),
              ),
              const SliverPadding(
                  padding: EdgeInsets.symmetric(vertical: 16.0)),
            ],
          );
        },
      ),
    );
  }
}
