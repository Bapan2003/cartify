import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:qit/core/app_helper.dart';

import '../../../../data/model/product_model.dart';
import '../../../../providers/product_provider.dart';
import '../../../../router/app_route.dart';

class TrendingDealsSection extends StatelessWidget {
  const TrendingDealsSection({super.key});

  @override
  Widget build(BuildContext context) {

    final bool isWeb = MediaQuery.of(context).size.width > 900;

    return StreamBuilder<QuerySnapshot>(
      stream: context.read<ProductProvider>().fetchTrendingDeals(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SizedBox.shrink();
        }

        final products = snapshot.data!.docs;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
              child: Text(
                "Trending Deals",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            // 🔹 Responsive layout for mobile/web
            isWeb
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                           SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount:
                                MediaQuery.of(context).size.width > 1200
                                ? 4
                                : MediaQuery.of(context).size.width > 800
                                ? 3
                                : 2, // responsive

                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 0.75,
                          ),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = Product.fromDoc(products[index]);

                        return SizedBox(
                          width: 160,
                          child: _ProductCard(
                            id: product.id,
                            title: product.productName,
                            image: product.imageUrls[0],
                            price: AppHelper.formatAmount(product.discountedPrice.toString()),
                            originalPrice: AppHelper.formatAmount(product.retailPrice.toString()),
                          ),
                        );
                      },
                    ),
                  )
                : SizedBox(
                    height: 240,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: products.length,
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      itemBuilder: (context, index) {
                        final product = Product.fromDoc(products[index]);

                        return SizedBox(
                          width: 160,
                          child: _ProductCard(
                            id: product.id,
                            title: product.productName,
                            image: product.imageUrls[0],
                            price: AppHelper.formatAmount(product.discountedPrice.toString()),
                            originalPrice: AppHelper.formatAmount(product.retailPrice.toString()),
                          ),
                        );
                      },
                    ),
                  ),
          ],
        );
      },
    );
  }
}

// 🔹 Extracted reusable card widget
class _ProductCard extends StatelessWidget {
  final String id;
  final String title;
  final String image;
  final String price;
  final String originalPrice;

  const _ProductCard({
    required this.id,
    required this.title,
    required this.image,
    required this.price,
    required this.originalPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: InkWell(
        onTap: () {
          context.pushNamed(
            AppRoute.productDetails,
            queryParameters: {'productId': id},
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🖼️ Product Image
            AspectRatio(
              aspectRatio: 1,
              child: Image.network(
                image,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.image_not_supported),
              ),
            ),

            // 📝 Product Details
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        "₹$price",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "₹$originalPrice",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
