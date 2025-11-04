import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/app_helper.dart';
import '../../../../data/model/product_model.dart';
import '../../../../router/app_route.dart';

class SimilarProductCard extends StatelessWidget {
  final Product product;
  const SimilarProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final discountPercent = ((product.retailPrice - product.discountedPrice) /
        product.retailPrice *
        100)
        .toInt();

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        context.pushNamed(
          AppRoute.productDetails,
          queryParameters: {'productId': product.id},
        );      },
      child: Container(
        width: 180,
        margin: const EdgeInsets.symmetric(horizontal: 5,).copyWith(bottom: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Product Image with Discount Tag
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.network(
                    product.imageUrls.isNotEmpty ? product.imageUrls.first : '',
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 150,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.image_outlined,
                          size: 50, color: Colors.grey),
                    ),
                  ),
                ),

                // 🔴 Discount Tag
                if (discountPercent > 0)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '-$discountPercent%',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 8),

            // 🏷️ Product Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                product.productName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
            ),

            const SizedBox(height: 6),

            // ⭐ Rating + Bought Info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 16),
                  const SizedBox(width: 3),
                  Text(
                    (product.rating ?? 4.3).toStringAsFixed(1),
                    style: const TextStyle(fontSize: 13),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "(${product.totalBought ?? 1200}+ bought)",
                    style: const TextStyle(
                        fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // 💰 Price Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "₹${AppHelper.formatAmount(product.discountedPrice.toString())}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "₹${AppHelper.formatAmount(product.retailPrice.toString())}",
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),


          ],
        ),
      ),
    );
  }
}
