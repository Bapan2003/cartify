import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProductReviewSection extends StatefulWidget {
  final String productId;
  final List<Map<String, dynamic>> initialReviews;

  const ProductReviewSection({
    Key? key,
    required this.productId,
    required this.initialReviews,
  }) : super(key: key);

  @override
  State<ProductReviewSection> createState() => _ProductReviewSectionState();
}

class _ProductReviewSectionState extends State<ProductReviewSection> {
  late final ValueNotifier<List<Map<String, dynamic>>> reviewsNotifier;
  late final ValueNotifier<bool> isLoadingNotifier;
  late final ValueNotifier<double> ratingNotifier;
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    reviewsNotifier = ValueNotifier(widget.initialReviews);
    isLoadingNotifier = ValueNotifier(false);
    ratingNotifier = ValueNotifier(0.0);
  }

  @override
  void dispose() {
    reviewsNotifier.dispose();
    isLoadingNotifier.dispose();
    ratingNotifier.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _addReview() async {
    final comment = _commentController.text.trim();
    final rating = ratingNotifier.value;

    if (rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please provide a rating")),
      );
      return;
    }

    isLoadingNotifier.value = true;

    final productRef = FirebaseFirestore.instance
        .collection('products')
        .doc(widget.productId);

    try {
      final doc = await productRef.get();
      if (!doc.exists) throw Exception("Product not found");

      final currentData = doc.data()!;
      final existingReviews = List<Map<String, dynamic>>.from(
        currentData['reviews'] ?? [],
      );
      final existingCount = (currentData['review_count'] ?? 0) as int;
      final currentAvg = (currentData['rating'] ?? 0).toDouble();

      if (comment.isNotEmpty) {
        final newReview = {
          'createdAt': Timestamp.now(),
          'comment': comment,
          'rating': rating,
        };

        reviewsNotifier.value = [...reviewsNotifier.value, newReview];

        await productRef.update({
          'reviews': FieldValue.arrayUnion([newReview]),
          'review_count': existingCount + 1,
        });

        final totalRatingsSum = (currentAvg * existingCount) + rating;
        final newAvg = totalRatingsSum / (existingCount + 1);

        await productRef.update({
          'rating': double.parse(newAvg.toStringAsFixed(1)),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Review added successfully!")),
        );
      } else {
        final newAvg = ((currentAvg * existingCount) + rating) / (existingCount + 1);

        await productRef.update({
          'review_count': existingCount + 1,
          'rating': double.parse(newAvg.toStringAsFixed(1)),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Rating submitted successfully!")),
        );
      }
    } catch (e) {
      debugPrint('Error adding/updating review: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    } finally {
      _commentController.clear();
      ratingNotifier.value = 0;
      isLoadingNotifier.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Customer Reviews",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          ValueListenableBuilder<List<Map<String, dynamic>>>(
            valueListenable: reviewsNotifier,
            builder: (context, reviews, _) {
              if (reviews.isEmpty) {
                return const Text(
                  "No reviews yet. Be the first to review!",
                  style: TextStyle(color: Colors.grey),
                );
              }

              return ListView.builder(
                itemCount: reviews.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (ctx, index) {
                  final item = reviews[index];
                  return _buildReview(
                    rating: (item['rating'] as num).toDouble(),
                    comment: item['comment'],
                    date: (item['createdAt'] as Timestamp).toDate(),
                  );
                },
              );
            },
          ),

          const SizedBox(height: 16),
          const Divider(thickness: 1),
          const SizedBox(height: 10),

          const Text(
            "Write a Review",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),

          // ⭐ Rating Stars
          ValueListenableBuilder<double>(
            valueListenable: ratingNotifier,
            builder: (context, rating, _) {
              return Row(
                children: List.generate(
                  5,
                      (index) => IconButton(
                    icon: Icon(
                      index < rating
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      color: Colors.amber,
                      size: 28,
                    ),
                    onPressed: () => ratingNotifier.value = index + 1.0,
                  ),
                ),
              );
            },
          ),

          TextField(
            controller: _commentController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Share your experience (optional)...',
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
            ),
          ),
          const SizedBox(height: 10),

          ValueListenableBuilder<bool>(
            valueListenable: isLoadingNotifier,
            builder: (context, isLoading, _) {
              return SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    backgroundColor: Colors.amber.shade700,
                  ),
                  onPressed: isLoading ? null : _addReview,
                  child: isLoading
                      ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                    ),
                  )
                      : const Text(
                    'Submit Review',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReview({
    required double rating,
    required String comment,
    required DateTime date,
  }) {
    final formattedDate = DateFormat('d MMM yyyy').format(date);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date & Rating
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                formattedDate,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
              Row(
                children: [
                  ...List.generate(
                    5,
                        (i) => Icon(
                      i < rating
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      color: Colors.amber,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    rating.toStringAsFixed(1),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (comment.isNotEmpty)
            Text(
              comment,
              style: const TextStyle(
                fontSize: 14,
                height: 1.4,
                color: Colors.black87,
              ),
            ),
        ],
      ),
    );
  }
}
