import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qit/core/app_helper.dart';

import '../../../../providers/cart_provider.dart';

class CartFooter extends StatelessWidget {
  final CartProvider cart;
  const CartFooter({required this.cart, super.key});

  @override
  Widget build(BuildContext context) {
    final itemTotal = cart.totalPrice;
    final deliveryCharge = itemTotal * 0.05;
    final cappedDelivery = deliveryCharge.clamp(40, 120); // 5% but 40–120 range
    final totalWithDelivery = itemTotal + cappedDelivery;
    final freeDelivery = cappedDelivery;
    final orderTotal = totalWithDelivery - freeDelivery;

    final baseStyle = Theme.of(context).textTheme.titleMedium!.copyWith(
      color: Colors.black87,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const SizedBox(height: 8),

        // 🧾 Items
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Items:', style: baseStyle),
            Text(
              '₹${AppHelper.formatAmount(itemTotal.toStringAsFixed(2))}',
              style: baseStyle.copyWith(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        const SizedBox(height: 4),

        // 🚚 Delivery
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Delivery:', style: baseStyle),
            Text(
              '₹${AppHelper.formatAmount(cappedDelivery.toStringAsFixed(2))}',
              style: baseStyle,
            ),
          ],
        ),
        const SizedBox(height: 4),

        // ➕ Total (Items + Delivery)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Total:', style: baseStyle),
            Text(
              '₹${AppHelper.formatAmount(totalWithDelivery.toStringAsFixed(2))}',
              style: baseStyle.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 4),

        // 💚 Free Delivery
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Free Delivery:', style: baseStyle),
            Text(
              '-₹${AppHelper.formatAmount(freeDelivery.toStringAsFixed(2))}',
              style: baseStyle.copyWith(
                color: Colors.green.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),

        const Divider(height: 24),

        // 🧮 Order Total
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Order Total:',
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '₹${AppHelper.formatAmount(orderTotal.toStringAsFixed(2))}',
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),
      ],
    );
  }
}


