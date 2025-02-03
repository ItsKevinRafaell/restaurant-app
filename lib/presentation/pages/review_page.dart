import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app/presentation/themes/typography/app_text_styles.dart';
import 'package:restaurant_app/presentation/providers/restaurant/providers/restaurant_review_provider.dart';

class ReviewPage extends StatefulWidget {
  final String restaurantId;

  const ReviewPage({super.key, required this.restaurantId});

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  final _nameController = TextEditingController();
  final _reviewController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _reviewController.dispose();
    super.dispose();
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  bool _validateInputs() {
    final name = _nameController.text.trim();
    final review = _reviewController.text.trim();

    if (name.isEmpty) {
      _showSnackBar(context, 'Nama tidak boleh kosong');
      return false;
    }

    if (review.isEmpty) {
      _showSnackBar(context, 'Ulasan tidak boleh kosong');
      return false;
    }

    return true;
  }

  void _submitReview(BuildContext context) async {
    if (!_validateInputs()) return;

    final provider = context.read<RestaurantReviewProvider>();
    try {
      await provider.postReview(
        widget.restaurantId,
        _nameController.text.trim(),
        _reviewController.text.trim(),
      );

      _nameController.clear();
      _reviewController.clear();

      _showSnackBar(context, 'Ulasan berhasil dikirim!');
      Navigator.pop(context);
    } catch (e) {
      _showSnackBar(context, 'Gagal mengirim ulasan: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tambah Ulasan', style: AppTextStyles.titleLarge),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nama',
                labelStyle: AppTextStyles.bodyMedium,
                border: const OutlineInputBorder(),
              ),
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _reviewController,
              decoration: InputDecoration(
                labelText: 'Ulasan',
                labelStyle: AppTextStyles.bodyMedium,
                border: const OutlineInputBorder(),
              ),
              style: AppTextStyles.bodyMedium,
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Consumer<RestaurantReviewProvider>(
              builder: (context, provider, child) {
                return provider.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : ElevatedButton(
                        onPressed: () => _submitReview(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          'Kirim Ulasan',
                          style: AppTextStyles.titleMedium
                              .copyWith(color: Colors.white),
                        ),
                      );
              },
            ),
          ],
        ),
      ),
    );
  }
}
