import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:qit/core/app_helper.dart';
import 'package:qit/data/model/product_model.dart';

import '../../../providers/search_providers.dart';
import '../../../router/app_route.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SearchProvider>(context);
    final bool isWeb = kIsWeb && MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
        actions: [
          // Sort dropdown
          DropdownButton<String>(
            value: provider.sortBy,
            items: [
              'Low to High',
              'High to Low',
              'A to Z',
              'Z to A',
              'Latest',
              'Oldest',
              'High Rating',
              'Low Rating'
            ]
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (value) {
              if (value != null) provider.setSortBy(value);
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_alt_outlined),
            onPressed: () => _showFilterSheet(context),
          ),
        ],
      ),
      body: provider.filteredProducts.isEmpty
          ? const Center(child: Text("No matching products"))
          : Padding(
        padding: const EdgeInsets.all(12),
        child: isWeb
            ? GridView.builder(
          gridDelegate:
          SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount:
            MediaQuery.of(context).size.width ~/ 220,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.75,
          ),
          itemCount: provider.filteredProducts.length,
          itemBuilder: (context, index) {
            final doc = provider.filteredProducts[index];
            final product = Product.fromDoc(doc);
            return _SearchItemCard(
              id: doc.id,
              title: product.productName,
              image: product.imageUrls[0] ?? '',
              price: product.discountedPrice,
              originalPrice: product.retailPrice,
            );
          },
        )
            : ListView.builder(
          itemCount: provider.filteredProducts.length,
          itemBuilder: (context, index) {
            final doc = provider.filteredProducts[index];
            final product = Product.fromDoc(doc);
            return _SearchListItem(
              id: doc.id,
              title: product.productName,
              image: product.imageUrls[0] ?? '',
              price: product.discountedPrice,
              originalPrice: product.retailPrice,
            );
          },
        ),
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    final provider = Provider.of<SearchProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            left: 20,
            right: 20,
            top: 20),
        child: Consumer<SearchProvider>(
          builder: (context, provider, _) => SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Shipping
                const Text('Shipping', style: TextStyle(fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    ChoiceChip(
                      label: const Text('Free'),
                      selected: provider.selectedShipping == 'Free',
                      onSelected: (_) => provider.setShipping('Free'),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Paid'),
                      selected: provider.selectedShipping == 'Paid',
                      onSelected: (_) => provider.setShipping('Paid'),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Discount
                const Text('Discount', style: TextStyle(fontWeight: FontWeight.bold)),
                Wrap(
                  spacing: 8,
                  children: ['All', '10% off', '25% off']
                      .map((e) => FilterChip(
                    label: Text(e),
                    selected: provider.selectedDiscounts.contains(e),
                    onSelected: (_) => provider.toggleDiscount(e),
                  ))
                      .toList(),
                ),
                const SizedBox(height: 10),

                // Brand
                const Text('Brand', style: TextStyle(fontWeight: FontWeight.bold)),
                Wrap(
                  spacing: 8,
                  children: provider.brands
                      .map((brand) => FilterChip(
                    label: Text(brand),
                    selected: provider.selectedBrands.contains(brand),
                    onSelected: (_) => provider.toggleBrand(brand),
                  ))
                      .toList(),
                ),
                const SizedBox(height: 10),

                // Category
                const Text('Category', style: TextStyle(fontWeight: FontWeight.bold)),
                Wrap(
                  spacing: 8,
                  children: provider.categories
                      .map((cat) => FilterChip(
                    label: Text(cat),
                    selected: provider.selectedCategories.contains(cat),
                    onSelected: (_) => provider.toggleCategory(cat),
                  ))
                      .toList(),
                ),
                const SizedBox(height: 10),

                // Value Pick
                Row(
                  children: [
                    const Text('Value Pick', style: TextStyle(fontWeight: FontWeight.bold)),
                    Switch(
                      value: provider.valuePick,
                      onChanged: (_) => provider.toggleValuePick(),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          provider.clearFilters(); // You need to implement this
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.amber.shade700, width: 1),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor: Colors.transparent,
                        ),
                        child: Text(
                          "Clear Filters",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.amber.shade700,
                          ),
                        ),
                      ),
                    ),
                    // const SizedBox(width: 10),
                    // Expanded(
                    //   child: ElevatedButton(
                    //     onPressed: () {
                    //       provider.applyFilters();
                    //       Navigator.pop(context);
                    //     },
                    //     style: ElevatedButton.styleFrom(
                    //       padding: const EdgeInsets.symmetric(vertical: 14),
                    //       textStyle: const TextStyle(
                    //           fontSize: 16,
                    //           fontWeight: FontWeight.w600,
                    //           color: Colors.white
                    //       ),
                    //       shape: RoundedRectangleBorder(
                    //         borderRadius: BorderRadius.circular(10),
                    //       ),
                    //       backgroundColor: Colors.amber.shade700,
                    //     ),
                    //     child: const Text('Apply Filters',style: TextStyle(color: Colors.white),),
                    //   ),
                    // ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchItemCard extends StatelessWidget {
  final String id;
  final String title;
  final String image;
  final num price;
  final num originalPrice;

  const _SearchItemCard({
    required this.id,
    required this.title,
    required this.image,
    required this.price,
    required this.originalPrice,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.pushNamed(
        AppRoute.productDetails,
        queryParameters: {'productId': id},
      ),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        clipBehavior: Clip.antiAlias,
        shadowColor: Colors.grey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Image.network(
                image,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.image_not_supported),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
                  Text(
                    "₹$price",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "₹$originalPrice",
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchListItem extends StatelessWidget {
  final String id;
  final String title;
  final String image;
  final num price;
  final num originalPrice;

  const _SearchListItem({
    required this.id,
    required this.title,
    required this.image,
    required this.price,
    required this.originalPrice,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => context.pushNamed(
        AppRoute.productDetails,
        queryParameters: {'productId': id},
      ),
      leading: Image.network(
        image,
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.image_not_supported),
      ),
      title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Row(
        children: [
          Text(
            "₹${AppHelper.formatAmount(price.toString())}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 6),
          Text(
            "₹${AppHelper.formatAmount(originalPrice.toString())}",
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              decoration: TextDecoration.lineThrough,
            ),
          ),
        ],
      ),
    );
  }
}
