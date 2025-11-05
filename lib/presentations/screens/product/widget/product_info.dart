import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:qit/presentations/screens/product/widget/product_review.dart';
import 'package:qit/presentations/screens/product/widget/quantity_dropdown.dart';
import 'package:qit/providers/cart_provider.dart';
import '../../../../core/app_helper.dart';
import '../../../../data/model/cart_item_model.dart';
import '../../../../data/model/product_model.dart';
import '../../../../router/app_route.dart';

class ProductInfoSection extends StatefulWidget {
  final Product product;

  const ProductInfoSection({super.key, required this.product});

  @override
  State<ProductInfoSection> createState() => _ProductInfoSectionState();
}

class _ProductInfoSectionState extends State<ProductInfoSection> {
  final selectedQtyNotifier = ValueNotifier<int>(1);

  @override
  void dispose() {
    selectedQtyNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final discountPercent =
        ((widget.product.retailPrice - widget.product.discountedPrice) /
                widget.product.retailPrice *
                100)
            .toInt();

    final bool isOutOfStock = widget.product.stock <= 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🏷️ Product Name
        Text(
          widget.product.productName,
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
              "${widget.product.rating.toStringAsFixed(1)} (${widget.product.reviewsCount} reviews)",
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const Spacer(),
            Text(
              "Brand: ${widget.product.brand}",
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
              "₹${AppHelper.formatAmount(widget.product.discountedPrice.toString())}",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              "₹${AppHelper.formatAmount(widget.product.retailPrice.toString())}",
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
              widget.product.isFreeShipping
                  ? Icons.local_shipping_outlined
                  : Icons.payments_outlined,
              color: Colors.teal,
              size: 18,
            ),
            const SizedBox(width: 6),
            Text(
              widget.product.isFreeShipping ? "Free Shipping" : "Paid Shipping",
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(width: 16),
            const Icon(
              Icons.restart_alt_rounded,
              color: Colors.blueAccent,
              size: 18,
            ),
            const SizedBox(width: 6),
            Text(
              "Return: ${widget.product.returnPolicy}",
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
                "(${widget.product.stock} left)",
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
            const Spacer(),
            Text(
              "${widget.product.totalBought}+ bought",
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
          widget.product.description,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
            height: 1.4,
          ),
        ),


        const SizedBox(height: 16),
        QuantityDropdown(
          maxQuantity: widget.product.stock,
          selectedQtyNotifier: selectedQtyNotifier,
        ),
        const SizedBox(height: 16),

        // ⚙️ Specifications
        if (widget.product.specifications != null &&
            widget.product.specifications!.isNotEmpty) ...[
          const Text(
            "Specifications",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...widget.product.specifications!.entries.map(
            (e) => Padding(
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
            ),
          ),
          const SizedBox(height: 16),
        ],



        // 🛒 Add to Cart Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              final qty = selectedQtyNotifier.value;

              context.read<CartProvider>().addToCart(
                CartModel.fromMap(widget.product.toJson(), widget.product.productName,qty: qty),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("${widget.product.productName} added to cart")),
              );
            },
            icon: const Icon(Icons.shopping_cart_outlined),
            label: const Text("Add to Cart"),
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
          ),
        ),
        const SizedBox(height: 12),

        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              final qty = selectedQtyNotifier.value;
              context.push(AppRoute.checkout ,extra: [CartModel.fromMap(widget.product.toJson(), widget.product.id,qty: qty)],);

            },
            icon: Icon(
              Icons.flash_on_rounded,
              color: Colors.amber.shade700,
            ),
            label: Text(
              "Buy Now",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.amber.shade700,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.amber.shade700, width: 1.8),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              backgroundColor: Colors.transparent,
            ),
          ),
        ),




        const SizedBox(height: 24),

        ProductReviewSection(
          productId: widget.product.id,
          initialReviews: widget.product.reviews,
        ),

      ],
    );
  }
}
