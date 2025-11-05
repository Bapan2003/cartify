import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:qit/core/app_helper.dart';
import 'package:qit/presentations/widgets/proceed_button.dart';
import 'package:qit/router/app_route.dart';

import '../../../../providers/cart_provider.dart';

class CartHeader extends StatelessWidget {
  final CartProvider cart;
  const CartHeader({required this.cart});

  @override
  Widget build(BuildContext context) {
    final itemTotal = cart.totalPrice;
    final deliveryCharge = itemTotal * 0.05;
    final cappedDelivery = deliveryCharge.clamp(40, 120); // 5%, min ₹40, max ₹120
    final subtotal = itemTotal + cappedDelivery;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.titleLarge, // base style
            children: [
              TextSpan(
                text: 'Subtotal ',
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  fontWeight: FontWeight.w400, // light
                  color: Colors.black,
                ),
              ),
              TextSpan(
                text:
                '₹${AppHelper.formatAmount(subtotal.toStringAsFixed(2))}', // ✅ updated amount
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  fontWeight: FontWeight.bold, // bold subtotal
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            "✅ Your order is eligible for FREE Delivery.",
            style: TextStyle(color: Colors.green, fontWeight: FontWeight.w500),
          ),
        ),
        ProceedButton(onPressed:()=>onPressed(context)),
        const Divider(height: 24),

      ],
    );
  }

  void onPressed(BuildContext context){
    context.push(AppRoute.checkout ,extra: context.read<CartProvider>().cartItems,);
  }
}
