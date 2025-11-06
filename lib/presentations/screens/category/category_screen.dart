// category_screen.dart
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:qit/core/app_helper.dart';
import 'package:qit/presentations/screens/category/widget/category_card.dart';

import '../../../providers/category_provider.dart';
import '../home/widget/new_arrival_section.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  bool _initializedForWeb = false;

  @override
  void initState() {
    super.initState();
    final provider = context.read<CategoryProvider>();

    // Fetch categories initially
    provider.fetchCategories().then((_) {
      if(!context.mounted)return;
      if (MediaQuery.of(context).size.width > 700 && provider.categories.isNotEmpty) {
        provider.fetchProductsByCategory(provider.categories.first);
      }
    });
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final provider = context.read<CategoryProvider>();
    final isWeb = MediaQuery.of(context).size.width > 700;

    if (isWeb && !_initializedForWeb) {
      _initializedForWeb = true;

      // Delay until after first frame so categories are loaded
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (provider.categories.isNotEmpty) {
          provider.fetchProductsByCategory(provider.categories.first);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CategoryProvider>();
    final isWeb = MediaQuery.of(context).size.width > 700;
    final isCategorySelected = provider.selectedCategory != null;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🧭 Sidebar (only for Web)
          if (isWeb)
            Container(
              width: 260,
              color: Colors.white,
              child: ListView(
                padding: const EdgeInsets.only(top: 16),
                children: [
                  for (final category in provider.categories)
                    ListTile(
                      title: Text(
                        category,
                        style: TextStyle(
                          fontWeight: provider.selectedCategory == category
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: provider.selectedCategory == category
                              ? Colors.deepOrange
                              : Colors.black87,
                        ),
                      ),
                      onTap: () => provider.fetchProductsByCategory(category),
                    ),
                ],
              ),
            ),

          // 🧩 Main Grid Area
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: provider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : isWeb
                    ? _buildProductGrid(context, provider, isWeb)
                    : isCategorySelected
                    ? _buildProductGrid(context, provider, isWeb)
                    : _buildCategoryGrid(context, provider, isWeb),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🧩 Category Grid (mobile only)
  Widget _buildCategoryGrid(
    BuildContext context,
    CategoryProvider provider,
    bool isWeb,
  ) {
    return GridView.builder(
      itemCount: provider.categories.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isWeb ? 5 : 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        final category = provider.categories[index];
        return CategoryCard(
          title: category,
          onTap: () => provider.fetchProductsByCategory(category),
        );
      },
    );
  }

  // 🧩 Product Grid
  Widget _buildProductGrid(
    BuildContext context,
    CategoryProvider provider,
    bool isWeb,
  ) {
    final products = provider.categoryProducts;
    if (products.isEmpty) {
      return const Center(
        child: Text(
          "No products found in this category",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }
    return GridView.builder(
      itemCount: products.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isWeb ? MediaQuery.of(context).size.width<900?2:4 : 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio:isWeb ?MediaQuery.of(context).size.width<900?0.65:0.75 : 0.75,
      ),
      itemBuilder: (context, index) => ProductCard(
        id: products[index].id,
        title: products[index].productName,
        image: products[index].imageUrls.first,
        price: AppHelper.formatAmount(
          products[index].discountedPrice.toStringAsFixed(2),
        ),
        originalPrice: AppHelper.formatAmount(
          products[index].retailPrice.toStringAsFixed(2),
        ),
      ),
    );
  }
}
