import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qit/presentations/screens/home/widget/new_arrival_section.dart';
import 'package:qit/presentations/screens/home/widget/trending_deel_section.dart';
import 'package:qit/providers/cart_provider.dart';
import '../../../data/model/product_model.dart';
import '../../../providers/product_provider.dart';
import '../../widgets/banner_widget.dart';
import '../../widgets/product_tile.dart';
import '../cart/cart_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProductProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;

    int crossAxisCount;
    double childAspectRatio;

    if (kIsWeb) {
      if (screenWidth > 1400) {
        crossAxisCount = 4;
        childAspectRatio = 0.7;
      } else if (screenWidth > 1000) {
        crossAxisCount = 4;
        childAspectRatio = 0.69;
      } else if (screenWidth > 700) {
        crossAxisCount = 3;
        childAspectRatio = 0.63;
      } else if (screenWidth > 650) {
        crossAxisCount = 3;
        childAspectRatio = 0.67;
      } else if (screenWidth > 400) {
        crossAxisCount = 2;
        childAspectRatio = 0.65;

      } else {
        crossAxisCount = 2;
        childAspectRatio = 0.55;
      }
    } else {
      // 📱 For Android/iOS
      crossAxisCount = 2;
      childAspectRatio =  0.62 ;
    }
    return Scaffold(
      body: SafeArea(
        child: Consumer<ProductProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return CustomScrollView(
              slivers: [
                // 🔹 Banner Section
                SliverToBoxAdapter(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      SizedBox(height: 12),
                      BannerWidget(),
                      SizedBox(height: 10),
                      TrendingDealsSection(),
                      SizedBox(height: 20),
                      NewArrivalsSection(),
                      SizedBox(height: 20),
                    ],
                  ),
                ),

                // 🔹 Product Grid Section
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount, // responsive
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,

                      childAspectRatio: childAspectRatio,
                    ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final product = provider.products[index];
                      return ProductTile(
                        product: product,
                        cartProvider: context.read<CartProvider>(),
                      );
                    }, childCount: provider.products.length),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
