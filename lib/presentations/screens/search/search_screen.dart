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
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip(context, provider, 'Free Shipping'),
                  _buildFilterChip(context, provider, 'Paid Shipping'),
                  _buildFilterChip(context, provider, 'iPhone'),
                  _buildFilterChip(context, provider, 'All Discounts'),
                  _buildFilterChip(context, provider, '10% off or more'),
                  _buildFilterChip(context, provider, '25% off or more'),
                  _buildFilterChip(context, provider, 'Include Out of Stock'),
                  _buildFilterChip(context, provider, 'Value Pick'),
                ],
              ),
            ),
          ),
          provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : provider.filteredProducts.isEmpty
              ? const Center(child: Text("No matching products"))
              : Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
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
                              return _SearchListItem(
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
                ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    SearchProvider provider,
    String label,
  ) {
    final isSelected = provider.selectedFilters.contains(label);
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        selected: isSelected,
        onSelected: (_) => provider.toggleFilter(label),
        selectedColor: const Color(0xFFFFA41C),
        // Amazon orange
        backgroundColor: Colors.white,
        side: BorderSide(color: Colors.orange.shade300),
        showCheckmark: false,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
