import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:qit/core/app_helper.dart';

import '../../data/model/product_model.dart';
import '../../providers/product_provider.dart';
import '../../router/app_route.dart';



class BannerWidget extends StatefulWidget {
  const BannerWidget({super.key});

  @override
  State<BannerWidget> createState() => _BannerWidgetState();
}

class _BannerWidgetState extends State<BannerWidget> {
  final PageController _controller = PageController(viewportFraction: 0.9);
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
  }

  void _startAutoSlide() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      final provider = context.read<ProductProvider>();
      final total = provider.bannerProducts.length;
      if (total > 1) {
        _currentIndex = (_currentIndex + 1) % total;
        if (mounted) {
          _controller.animateToPage(
            _currentIndex,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProductProvider>(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (provider.bannerProducts.isEmpty && !provider.isBannerLoading) {
        provider.fetchBannerProducts();
      }
    });

    if (provider.isBannerLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final banners = provider.bannerProducts;
    if (banners.isEmpty) {
      return const SizedBox.shrink();
    }

    final isIOS = defaultTargetPlatform == TargetPlatform.iOS;

    return Column(
      children: [
        SizedBox(
          height: 250,
          child: PageView.builder(
            controller: _controller,
            itemCount: banners.length,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
            },
            itemBuilder: (context, index) {
              final product = banners[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6.0),
                child: _BannerCard(product: product, isIOS: isIOS),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        _DotIndicator(
          itemCount: banners.length,
          currentIndex: _currentIndex,
          isIOS: isIOS,
        ),
      ],
    );
  }
}

class _BannerCard extends StatelessWidget {
  final Product product;
  final bool isIOS;

  const _BannerCard({required this.product, required this.isIOS});

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(16);

    return GestureDetector(
      onTap: () {
        context.pushNamed(
          AppRoute.productDetails,
          queryParameters: {'productId': product.id},
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: borderRadius,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 🔹 Product Image
              Image.network(
                product.imageUrls[0],
                fit: BoxFit.cover,errorBuilder: (_,__,___)=>Icon(Icons.error),
              ),

              // 🔹 Gradient Overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ),

              // 🔹 Text Overlay
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.productName,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isIOS ? 20 : 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          "₹${AppHelper.formatAmount(product.discountedPrice.toStringAsFixed(0))}",
                          style: TextStyle(
                            color: isIOS ? CupertinoColors.white : Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "₹${AppHelper.formatAmount(product.retailPrice.toStringAsFixed(0))}",
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      product.description.length > 60
                          ? "${product.description.substring(0, 60)}..."
                          : product.description,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DotIndicator extends StatelessWidget {
  final int itemCount;
  final int currentIndex;
  final bool isIOS;

  const _DotIndicator({
    required this.itemCount,
    required this.currentIndex,
    required this.isIOS,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(itemCount, (index) {
        final isActive = index == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          height: 8,
          width: isActive ? 18 : 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: isActive ? null : Colors.grey.shade400, // only for inactive
            gradient: isActive
                ? const LinearGradient(
              colors: [
                Color(0xFFF05A28),
                Color(0xFFF8B500),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
                : null,
          ),
        );
      }),
    );
  }
}

