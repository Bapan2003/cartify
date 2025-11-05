import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:qit/presentations/widgets/gradient_bar.dart';
import 'package:qit/providers/dashboard_provider.dart';

class CheckoutSuccessScreen extends StatelessWidget {
  const CheckoutSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isWeb = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(flexibleSpace:const GradientBar(),automaticallyImplyLeading: false,),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isWeb ? 500 : double.infinity,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ✅ Success Animation
                if(!kIsWeb)
                Lottie.asset(
                  'assets/images/success.json',
                  width: isWeb ? 250 : 200,
                  repeat: false,
                )
                else
                  Image.asset('assets/images/success.gif',width: 250,),

                const SizedBox(height: 20),

                // ✅ Title
                Text(
                  "Order Placed Successfully!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isWeb ? 28 : 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),

                const SizedBox(height: 10),

                // ✅ Description
                Text(
                  "Thank you for your purchase. Your order is being processed and we’ll notify you once it’s shipped.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isWeb ? 16 : 14,
                    color: Colors.grey[700],
                  ),
                ),

                const SizedBox(height: 40),

                // ✅ Continue Shopping Button
                SizedBox(
                  width: isWeb ? 220 : double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      context.read<DashboardProvider>().setIndex(0);
                      Navigator.pop(context); // Navigate back or home
                    },
                    child: const Text(
                      "Continue Shopping",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
