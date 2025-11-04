import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qit/providers/cart_provider.dart';
import '../../../../core/app_helper.dart';
import '../../../../data/model/cart_item_model.dart';
import '../../../../data/model/product_model.dart';

class ProductInfoSection extends StatelessWidget {
  final Product product;
  const ProductInfoSection({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final discountPercent = ((product.retailPrice - product.discountedPrice) /
        product.retailPrice *
        100)
        .toInt();

    final bool isOutOfStock = product.stock <= 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🏷️ Product Name
        Text(
          product.productName,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 8),

        // ⭐ Rating + Reviews + Brand
        Row(
          children: [
            Icon(Icons.star, color: Colors.amber.shade700, size: 18),
            const SizedBox(width: 4),
            Text(
              "${product.rating.toStringAsFixed(1)} (${product.reviewsCount} reviews)",
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const Spacer(),
            Text(
              "Brand: ${product.brand}",
              style: const TextStyle(
                fontSize: 14,
                color: Colors.blueAccent,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 💰 Price Section
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "₹${AppHelper.formatAmount(product.discountedPrice.toString())}",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              "₹${AppHelper.formatAmount(product.retailPrice.toString())}",
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
                decoration: TextDecoration.lineThrough,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              "-$discountPercent%",
              style: const TextStyle(
                fontSize: 14,
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 🚚 Shipping & Return
        Row(
          children: [
            Icon(
              product.isFreeShipping
                  ? Icons.local_shipping_outlined
                  : Icons.payments_outlined,
              color: Colors.teal,
              size: 18,
            ),
            const SizedBox(width: 6),
            Text(
              product.isFreeShipping
                  ? "Free Shipping"
                  : "Paid Shipping",
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(width: 16),
            const Icon(Icons.restart_alt_rounded, color: Colors.blueAccent, size: 18),
            const SizedBox(width: 6),
            Text(
              "Return: ${product.returnPolicy}",
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 📦 Stock + Bought Info
        Row(
          children: [
            Text(
              isOutOfStock ? "Out of Stock" : "In Stock",
              style: TextStyle(
                color: isOutOfStock ? Colors.red : Colors.green,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            if (!isOutOfStock)
              Text(
                "(${product.stock} left)",
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
            const Spacer(),
            Text(
              "${product.totalBought}+ bought",
              style: const TextStyle(color: Colors.blueGrey, fontSize: 13),
            ),
          ],
        ),

        const SizedBox(height: 18),

        // 🧾 Description
        const Text(
          "Product Description",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Text(
          product.description,
          style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.4),
        ),

        const SizedBox(height: 16),

        // ⚙️ Specifications
        if (product.specifications != null && product.specifications!.isNotEmpty) ...[
          const Text(
            "Specifications",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...product.specifications!.entries.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    "${e.key}:",
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    e.value.toString(),
                    style: const TextStyle(color: Colors.black87),
                  ),
                ),
              ],
            ),
          )),
          const SizedBox(height: 16),
        ],

        // 🛒 Add to Cart Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              context.read<CartProvider>().addToCart(
                CartModel.fromMap(product.toJson(), product.productName),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("${product.productName} added to cart")),
              );
            },
            icon: const Icon(Icons.shopping_cart_outlined),
            label: const Text("Add to Cart"),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              backgroundColor: Colors.amber.shade700,
            ),
          ),
        ),
        const SizedBox(height: 12),

        // ❤️ Wishlist
        Center(
          child: TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.favorite_border, color: Colors.redAccent),
            label: const Text("Add to Wishlist"),
          ),
        ),
      ],
    );
  }
}
