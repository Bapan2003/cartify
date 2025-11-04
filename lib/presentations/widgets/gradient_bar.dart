import 'package:flutter/material.dart';

class GradientBar extends StatelessWidget {
  const GradientBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFF05A28),
            Color(0xFFF8B500),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }
}
