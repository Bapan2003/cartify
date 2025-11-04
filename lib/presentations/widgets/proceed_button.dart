import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform;

class ProceedButton extends StatelessWidget {
  final VoidCallback onPressed;

  const ProceedButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final bool isIOS = !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

    // Responsive width for web / large screens
    final double maxWidth = MediaQuery.of(context).size.width > 600 ? 600 : double.infinity;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: isIOS
              ? CupertinoButton(
            borderRadius: BorderRadius.circular(10),
            color: const Color(0xFFFFA41C), // Amazon-like orange
            padding: const EdgeInsets.symmetric(vertical: 14),
            onPressed: onPressed,
            child: const Text(
              "Proceed to Buy",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.4,
              ),
            ),
          )
              : ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFA41C), // Amazon orange
              foregroundColor: Colors.white,
              shadowColor: Colors.orangeAccent.withOpacity(0.4),
              elevation: 3,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              minimumSize: const Size.fromHeight(50),
            ),
            onPressed: onPressed,
            child:Text(
              "Proceed to Buy",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ),
      ),
    );

  }
}
