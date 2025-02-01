import 'package:flutter/material.dart';
import 'package:restaurant_app/domain/entities/restaurant_list_model.dart';
import 'package:restaurant_app/presentation/themes/typography/app_text_styles.dart';

class RestaurantCard extends StatelessWidget {
  final Restaurant restaurant;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final bool isFavorite;
  final bool showFavoriteIcon;
  final bool showDeleteIcon;
  final VoidCallback? onFavoriteToggle;

  const RestaurantCard({
    super.key,
    required this.onTap,
    required this.restaurant,
    this.onDelete,
    this.isFavorite = false,
    this.showFavoriteIcon = true,
    this.showDeleteIcon = false,
    this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    final String restaurantName = restaurant.name ?? 'No name available';
    final String restaurantCity = restaurant.city ?? 'No city available';
    final String restaurantDescription =
        restaurant.description ?? 'No description available';
    final String restaurantPictureId =
        restaurant.pictureId ?? 'default_image.png';
    final double restaurantRating = restaurant.rating ?? 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Hero(
                  tag: restaurant.id ?? '',
                  child: Image.network(
                    'https://restaurant-api.dicoding.dev/images/small/${restaurantPictureId}',
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 100,
                        height: 100,
                        color: Colors.grey[300],
                        child: const Icon(Icons.error),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      restaurantName,
                      style: AppTextStyles.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          restaurantCity,
                          style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      restaurantDescription,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          "$restaurantRating",
                          style: AppTextStyles.bodyMedium
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (showFavoriteIcon || showDeleteIcon)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (showFavoriteIcon)
                      IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : null,
                        ),
                        onPressed: onFavoriteToggle,
                      ),
                    if (showDeleteIcon)
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: onDelete,
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
