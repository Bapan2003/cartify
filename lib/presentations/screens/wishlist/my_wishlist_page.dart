import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:go_router/go_router.dart';


import 'package:provider/provider.dart';
import 'package:qit/core/app_helper.dart';
import 'package:qit/data/model/cart_item_model.dart';
import 'package:qit/data/model/product_model.dart';

import '../../../providers/cart_provider.dart';
import '../../../providers/wishlist_provider.dart';
import '../../../router/app_route.dart';


class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = context.read<WishlistProvider>().userId;
    final firestore = FirebaseFirestore.instance;

    if (userId.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text(
            "Please log in to view your wishlist.",
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ),
      );
    }

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: StreamBuilder<List<String>>(
            stream: context.read<WishlistProvider>().wishlistStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox.shrink();
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const SizedBox.shrink();
              }

              // ✅ Extract wishlist product IDs
              final wishlistItems = snapshot.data!;

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 16.0, vertical: 15),
                      child: const Text(
                        'Saved Products',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    ListView.separated(
                      primary: false,
                      padding: const EdgeInsets.all(16),
                      shrinkWrap: true,
                      itemCount: wishlistItems.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final productId = wishlistItems[index];

                        return StreamBuilder<DocumentSnapshot>(
                          stream: firestore
                              .collection('products')
                              .doc(productId)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return Container(
                                height: 140,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Center(
                                    child: CircularProgressIndicator()),
                              );
                            }

                            final product = Product.fromDoc(snapshot.data!);

                            return InkWell(
                              onTap: () {
                                context.pushNamed(
                                  AppRoute.productDetails,
                                  queryParameters: {'productId': product.id},
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    // 🖼 Product Image
                                    Expanded(
                                      flex: 1,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          product.imageUrls.first,
                                          height: 130,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => Container(
                                            height: 130,
                                            color: Colors.grey.shade200,
                                            child: const Icon(Icons.image_not_supported,
                                                size: 40),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),

                                    // 🧾 Product Details
                                    Expanded(
                                      flex: 2,
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            product.productName,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            "by ${product.brand}",
                                            style:
                                            const TextStyle(color: Colors.grey),
                                          ),
                                          const SizedBox(height: 6),

                                          // ⭐ Rating
                                          Row(
                                            children: [
                                              RatingBarIndicator(
                                                rating: product.rating,
                                                itemBuilder: (context, _) =>
                                                const Icon(Icons.star,
                                                    color: Colors.amber),
                                                itemSize: 18,
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                "(${product.reviewsCount})",
                                                style: const TextStyle(
                                                    color: Colors.grey),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),

                                          // 💰 Price
                                          Row(
                                            children: [
                                              Text(
                                                "₹${AppHelper.formatAmount(product.discountedPrice.toString())}",
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.green,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                "₹${AppHelper.formatAmount(product.retailPrice.toString())}",
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey,
                                                  decoration:
                                                  TextDecoration.lineThrough,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            product.isFreeShipping
                                                ? 'Free'
                                                : 'Paid',
                                            style: const TextStyle(
                                              color: Colors.blueGrey,
                                              fontSize: 13,
                                            ),
                                          ),
                                          const SizedBox(height: 10),

                                          // 🛒 Buttons
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Consumer<CartProvider>(
                                                  builder: (context, cartProvider, _) {
                                                    final isAdded = cartProvider
                                                        .isInCart(productId);

                                                    return ElevatedButton.icon(
                                                      onPressed: () {
                                                        if (!isAdded) {
                                                          cartProvider.addToCart(
                                                            CartModel.fromMap(
                                                              product.toJson(),
                                                              productId,
                                                            ),
                                                          );
                                                          ScaffoldMessenger.of(context)
                                                              .showSnackBar(SnackBar(
                                                            content: Text(
                                                                "${product.productName} added to cart"),
                                                          ));
                                                        } else {
                                                          cartProvider.removeFromCart(
                                                            CartModel.fromMap(
                                                              product.toJson(),
                                                              productId,
                                                            ),
                                                          );
                                                          ScaffoldMessenger.of(context)
                                                              .showSnackBar(SnackBar(
                                                            content: Text(
                                                                "${product.productName} removed from cart"),
                                                          ));
                                                        }
                                                      },
                                                      icon: Icon(
                                                        isAdded
                                                            ? Icons.delete
                                                            : Icons
                                                            .shopping_cart_outlined,
                                                        color: Colors.white,
                                                      ),
                                                      label: Text(
                                                        isAdded
                                                            ? "Remove from Cart"
                                                            : "Add to Cart",
                                                        style: const TextStyle(
                                                            color: Colors.white),
                                                      ),
                                                      style:
                                                      ElevatedButton.styleFrom(
                                                        padding:
                                                        const EdgeInsets.symmetric(
                                                            vertical: 14),
                                                        textStyle: const TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                            FontWeight.w600),
                                                        shape:
                                                        RoundedRectangleBorder(
                                                          borderRadius:
                                                          BorderRadius.circular(
                                                              18),
                                                        ),
                                                        backgroundColor: isAdded
                                                            ? Colors.amber.shade700
                                                            : Colors.grey,
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.delete_outline,
                                                  color: Colors.red,
                                                ),
                                                onPressed: () async {
                                                  await firestore
                                                      .collection('users')
                                                      .doc(userId)
                                                      .collection('wishlist')
                                                      .doc(productId)
                                                      .delete();
                                                },
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
                          },
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

