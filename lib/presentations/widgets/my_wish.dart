import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/wishlist_provider.dart';

class WishButton extends StatefulWidget {
  final String id;
  const WishButton({super.key, required this.id});

  @override
  State<WishButton> createState() => _WishButtonState();
}

class _WishButtonState extends State<WishButton> with SingleTickerProviderStateMixin {
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
    return Selector<WishlistProvider, bool>(
      selector: (_, provider) => provider.isInWishlist(widget.id),
      builder: (_, isWishlisted, __) {
        final wishlistProvider = context.read<WishlistProvider>();

        return InkWell(
          onTap: () async {
            if (isWishlisted) {
              await wishlistProvider.removeFromWishlist(widget.id);
            } else {
              await wishlistProvider.addToWishlist(widget.id);
            }
            _animate(); // trigger animation
          },
          child: AnimatedBuilder(
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
          ),
        );
      },
    );
  }
}


