import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app/presentation/providers/restaurant/restaurant_detail_provider.dart';
import 'package:restaurant_app/presentation/providers/restaurant/restaurant_review_provider.dart';
import 'package:restaurant_app/presentation/providers/restaurant/restaurant_review_result_state.dart';

class ReviewPage extends StatefulWidget {
  final String restaurantId;

  const ReviewPage({Key? key, required this.restaurantId}) : super(key: key);

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _reviewController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _submitReview(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      final review = _reviewController.text.trim();

      if (name.isNotEmpty && review.isNotEmpty) {
        final provider = context.read<RestaurantReviewProvider>();
        final detailProvider = context.read<RestaurantDetailProvider>();
        try {
          await provider.postReview(widget.restaurantId, name, review);

          _nameController.clear();
          _reviewController.clear();
          await detailProvider.fetchRestaurantDetail(widget.restaurantId);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ulasan berhasil dikirim!'),
            ),
          );

          Navigator.pop(context);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal mengirim ulasan: $e'),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Ulasan'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _reviewController,
                decoration: const InputDecoration(
                  labelText: 'Ulasan',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ulasan tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => _submitReview(context),
                child: const Text(
                  'Kirim Ulasan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
