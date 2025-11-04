import 'package:flutter/material.dart';

class CartHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  CartHeaderDelegate({required this.child});

  @override
  double get minExtent => kToolbarHeight;
  @override
  double get maxExtent => kToolbarHeight;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Material(
      elevation: overlapsContent ? 4 : 0,
      color: Theme.of(context).colorScheme.surface,
      child: child,
    );
  }

  @override
  bool shouldRebuild(CartHeaderDelegate oldDelegate) => false;
}
