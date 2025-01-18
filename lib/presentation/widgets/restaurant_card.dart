import 'package:flutter/material.dart';
import 'package:restaurant_app/data/models/restaurant_list_model.dart';

class RestaurantCard extends StatelessWidget {
  final Restaurant restaurant; // Tambahkan parameter deskripsi
  final Function() onTap;

  const RestaurantCard({
    Key? key,
    required this.onTap,
    required this.restaurant,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              'https://restaurant-api.dicoding.dev/images/small/${restaurant.pictureId}',
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
          title: Text(
            restaurant.name!, // Tampilkan nama restoran
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    restaurant.city!, // Tampilkan kota
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                restaurant.description!, // Tampilkan deskripsi
                maxLines: 1, // Batasi hanya satu baris
                overflow: TextOverflow
                    .ellipsis, // Tambahkan ellipsis jika teks terlalu panjang
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.star, size: 16, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text(
                    "${restaurant.rating}", // Tampilkan rating
                    style: const TextStyle(fontWeight: FontWeight.bold),
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
