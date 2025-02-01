import 'package:flutter/material.dart';
import 'package:restaurant_app/presentation/themes/typography/app_text_styles.dart';

class MenuItemCard extends StatelessWidget {
  final String itemName;
  final String imageUrl;

  const MenuItemCard({
    super.key,
    required this.itemName,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: SizedBox(
        width: 120,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                imageUrl,
                height: 80,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 80,
                  width: double.infinity,
                  color: Colors.grey[300],
                  child: const Icon(Icons.restaurant_menu, color: Colors.grey),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  itemName,
                  style: AppTextStyles.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
