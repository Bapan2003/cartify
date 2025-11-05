import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qit/presentations/screens/cart/widget/cart_footer.dart';
import 'package:qit/presentations/screens/cart/widget/cart_header.dart';
import 'package:qit/presentations/screens/cart/widget/cart_item.dart';
import '../../../providers/cart_provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final platform = Theme.of(context).platform;
    final cart = context.watch<CartProvider>();
    final size = MediaQuery.of(context).size ;

    final isWeb = kIsWeb && size.width > 800;

    final body = cart.cartItems.isEmpty
        ? Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              "Your cart is empty",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Text(
              "Please add some products to your cart.",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    )
        :isWeb
        ? Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 32.0,
              vertical: 16.0,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🛒 Cart Items (center)
                Expanded(
                  flex: 2,
                  child: CustomScrollView(
                    slivers: [
                      SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final item = cart.cartItems[index];
                          return CartItemCard(item: item, cart: cart);
                        }, childCount: cart.cartItems.length),
                      ),
                      SliverToBoxAdapter(child: const SizedBox(height: 100)),
                    ],
                  ),
                ),

                const SizedBox(width: 32),

                // 📦 Sticky Cart Summary (right side)
                Expanded(
                  flex: 1,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        physics: const NeverScrollableScrollPhysics(),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: IntrinsicHeight(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Card(
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: CartHeader(cart: cart),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Card(
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: CartFooter(cart: cart),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          )
        // 📱 Mobile layout (unchanged)
        : CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: CartHeader(cart: cart),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final item = cart.cartItems[index];
                  return CartItemCard(item: item, cart: cart);
                }, childCount: cart.cartItems.length),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: CartFooter(cart: cart),
                ),
              ),
            ],
          );

    if (platform == TargetPlatform.iOS) {
      return CupertinoPageScaffold(
        child: SafeArea(
          child: body,
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: body,
      ),
    );
  }
}
