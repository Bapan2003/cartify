import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qit/core/app_helper.dart';
import 'package:qit/presentations/screens/home/widget/new_arrival_section.dart';
import 'package:qit/presentations/screens/product/widget/similar_product_card.dart';
import 'package:qit/presentations/widgets/product_tile.dart';
import '../../../../data/model/product_model.dart';

class SimilarProductsSection extends StatelessWidget {
  final Product currentProduct;
  final Axis axis;

  const SimilarProductsSection({
    super.key,
    required this.currentProduct,
    this.axis = Axis.horizontal,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: const Text(
            "Similar Products",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 12),

        // 🔍 Fetch Similar Products
        Flexible(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('products')
                .where('category', isEqualTo: currentProduct.category)
                .limit(10)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const SizedBox.shrink();
              }

              // 🧠 Convert Firestore docs to Product models
              final products = snapshot.data!.docs
                  .map((doc) => Product.fromDoc(doc))
                  .where(
                    (p) =>
                        p.id != currentProduct.id && // Exclude the same product
                        (p.subCategory == currentProduct.subCategory ||
                            p.brand == currentProduct.brand ||
                            p.category == currentProduct.category),
                  )
                  .toList();

              if (products.isEmpty) {
                return const SizedBox.shrink();
              }

              return SizedBox(
                      height: 280,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: products.length,
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),

                        itemBuilder: (context, index) {
                          final product = products[index];
                          return SimilarProductCard(product: product);
                        },
                      ),
                    );
            },
          ),
        ),
      ],
    );
  }
}
