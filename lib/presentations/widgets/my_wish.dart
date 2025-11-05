import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/wishlist_provider.dart';

class WishButton extends StatefulWidget {
  final String id;
  const WishButton({required this.id, super.key});

  @override
  State<WishButton> createState() => _WishButtonState();
}

class _WishButtonState extends State<WishButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      lowerBound: 0.7,
      upperBound: 1.2,
      value: 1,
    );
  }

  void _animate() {
    _controller.forward().then((_) => _controller.reverse());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wishlistProvider = context.read<WishlistProvider>();

    return InkWell(
      onTap: () {
        final isWishlisted = wishlistProvider.isInWishlist(widget.id);
        if (isWishlisted) {
          wishlistProvider.removeFromWishlist(widget.id);
        } else {
          wishlistProvider.addToWishlist(widget.id);
        }
        _animate(); // trigger animation
      },
      child: Selector<WishlistProvider, bool>(
        selector: (_, s) => s.isInWishlist(widget.id),
        builder: (_, isWishlisted, __) {
          return AnimatedBuilder(
            animation: _controller,
            builder: (_, child) {
              return Transform.scale(
                scale: _controller.value,
                child: child,
              );
            },
            child: Icon(
              isWishlisted ? Icons.favorite : Icons.favorite_border,
              color: isWishlisted ? Colors.red : Colors.grey,
              size: 28,
            ),
          );
        },
      ),
    );
  }
}

