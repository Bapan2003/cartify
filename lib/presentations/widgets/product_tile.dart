import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:qit/core/app_helper.dart';
import 'package:qit/data/model/cart_item_model.dart';
import '../../../providers/cart_provider.dart';
import '../../data/model/product_model.dart';

import 'package:flutter/material.dart';

import '../../router/app_route.dart';

class ProductTile extends StatefulWidget {
  final Product product;
  final CartProvider cartProvider;

  const ProductTile({
    super.key,
    required this.product,
    required this.cartProvider,
  });

  @override
  State<ProductTile> createState() => _ProductTileState();
}

class _ProductTileState extends State<ProductTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final cartProvider = widget.cartProvider;

    final isWeb = MediaQuery.of(context).size.width > 600;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: _isHovered
              ? [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            )
          ]
              : [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 3,
              spreadRadius: 1,
            ),
          ],
          border: Border.all(
            color: _isHovered ? Colors.blueAccent.withOpacity(0.5) : Colors.grey.shade300,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            context.pushNamed(
              AppRoute.productDetails,
              queryParameters: {'productId': product.id},
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🖼️ Image
              AspectRatio(
                aspectRatio: 1,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.network(
                    product.imageUrls.isNotEmpty ? product.imageUrls[0] : '',
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported, size: 50),
                  ),
                ),
              ),

              // 📝 Product Info
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.productName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          "₹${AppHelper.formatAmount(product.discountedPrice.toString())}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "₹${AppHelper.formatAmount(product.retailPrice.toString())}",
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

              // 🛒 Add to Cart Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: SizedBox(
                  width: double.infinity,
                  child: Selector<CartProvider,bool>(  // or CheckoutProvider
                    builder: (context, isCartItem, child) {
                      final isAdded = isCartItem; // implement this method in your provider

                      return ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isAdded ? Colors.orange : (_isHovered ? Colors.orange : Colors.grey),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          if (!isAdded) {
                            cartProvider.addToCart(
                              CartModel.fromMap(product.toJson(), product.id),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("${product.productName} added to cart")),
                            );
                          } else {
                            // optional: navigate to checkout or show a message
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("${product.productName} is already in cart")),
                            );
                          }
                        },
                        icon: Icon(isAdded ? Icons.check : Icons.add_shopping_cart, size: 18),
                        label: Text(isAdded ? "Added" : "Add"),
                      );
                    },
                    selector: (_,state)=>state.isInCart(product.id),
                  ),
                ),
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
