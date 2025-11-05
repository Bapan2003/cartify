import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qit/core/app_helper.dart';
import 'package:qit/data/model/cart_item_model.dart';

import '../../../../providers/cart_provider.dart';

class CartItemCard extends StatelessWidget {
  final CartModel item;
  final CartProvider cart;

  const CartItemCard({required this.item, required this.cart, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 🖼 Product image
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.network(
              item.image,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (_,__,___)=>SizedBox(
                  width: 80,
                  height: 80,
                  child: Icon(Icons.error)),
            ),
          ),
          const SizedBox(width: 12),

          // 🧾 Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 4),

                Text(
                  "₹${AppHelper.formatAmount(item.discountedPrice.toString())}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),

                // Quantity + Delete
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        if (item.quantity > 1) {
                          cart.updateQuantity(item, item.quantity - 1);
                        }
                      },
                      borderRadius: BorderRadius.circular(4),
                      child: const Icon(Icons.remove_circle_outline, size: 22),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        "${item.quantity}",
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                    ),
                    InkWell(
                      onTap: () => cart.updateQuantity(item, item.quantity + 1),
                      borderRadius: BorderRadius.circular(4),
                      child: const Icon(Icons.add_circle_outline, size: 22),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.redAccent,
                        size: 22,
                      ),
                      tooltip: 'Remove item',
                      onPressed: () => cart.removeFromCart(item),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
