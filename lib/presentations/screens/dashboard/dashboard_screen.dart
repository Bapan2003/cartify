import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qit/presentations/screens/search/search_screen.dart';
import 'package:qit/presentations/widgets/gradient_bar.dart';
import 'package:qit/providers/category_provider.dart';
import 'package:tuple/tuple.dart';

import '../../../providers/dashboard_provider.dart';
import '../../../providers/search_providers.dart';
import '../cart/cart_screen.dart';
import '../category/category_screen.dart';
import '../home/home_screen.dart';
import '../profile/profile_screen.dart';
import '../search/search_suggestion_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  static final List<Widget> _pages = [
    const HomeScreen(),
    const CategoryScreen(),
    const CartScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DashboardProvider>();
    final size = MediaQuery.of(context).size;
    final isWeb = kIsWeb && size.width > 800;

    if (isWeb) {
      return Scaffold(
        backgroundColor: Colors.grey.shade100,
        body: Column(
          children: [
            Container(
              height: 70,
              padding: const EdgeInsets.symmetric(horizontal: 24),
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
              child: Row(
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.shopping_bag,
                        color: Colors.white,
                        size: 32,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Amazon Clone",
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(width: 40),

                  // 🔍 Search bar
                  Expanded(
                    child: Container(
                      height: 45,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Selector<SearchProvider, String>(
                        selector: (_, s) => s.query,
                        builder: (_, query, __) {
                          return Row(
                            children: [
                              const SizedBox(width: 12),
                              const Icon(Icons.search, color: Colors.grey),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: TextEditingController(
                                    text: context.read<SearchProvider>().query,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: "Search for products, brands and more",
                                    border: InputBorder.none,
                                    hintStyle: TextStyle(color: Colors.grey.shade600),
                                  ),
                                  onChanged: (value) {
                                    context.read<SearchProvider>().updateQuery(value);
                                  },
                                  onTap: () async {
                                    final result = await showDialog<String>(
                                      context: context,
                                      barrierDismissible: true,
                                      builder: (_) => Dialog(
                                        insetPadding: const EdgeInsets.symmetric(horizontal: 300, vertical: 100),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const SizedBox(
                                          height: 600,
                                          width: 600,
                                          child: SearchSuggestionPage(),
                                        ),
                                      ),
                                    );

                                    if (!context.mounted) return;
                                    if (result != null && result.isNotEmpty) {
                                      context.read<SearchProvider>().updateQuery(result);
                                    }
                                  },
                                  onSubmitted: (value) {
                                    context.read<SearchProvider>().updateQuery(value);
                                  },
                                ),
                              ),
                              if (query.isNotEmpty)
                                IconButton(
                                  icon: const Icon(Icons.close, color: Colors.grey, size: 20),
                                  splashRadius: 18,
                                  tooltip: 'Clear',
                                  onPressed: () {
                                    context.read<SearchProvider>().updateQuery('');
                                  },
                                ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(width: 40),

                  // Account + Cart icons
                  Row(
                    children: [
                      _TopNavIcon(
                        icon: Icons.person_outline,
                        label: "Account",
                        isSelected: provider.currentIndex == 3,
                        onTap: () => provider.setIndex(3),
                      ),
                      const SizedBox(width: 16),
                      _TopNavIcon(
                        icon: Icons.shopping_cart_outlined,
                        label: "Cart",
                        isSelected: provider.currentIndex == 2,
                        onTap: () => provider.setIndex(2),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 🧭 Below topbar: Categories sidebar + main content
            Expanded(
              child: Row(
                children: [
                  // 📂 Left category sidebar
                  Container(
                    width: 220,
                    color: Colors.white,
                    child: ListView(
                      children: [
                        _CategoryTile(
                          icon: Icons.home_outlined,
                          label: "Home",
                          selected: provider.currentIndex == 0,
                          onTap: () => provider.setIndex(0),
                        ),
                        _CategoryTile(
                          icon: Icons.category_outlined,
                          label: "Categories",
                          selected: provider.currentIndex == 1,
                          onTap: () => provider.setIndex(1),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: context.watch<SearchProvider>().query.isNotEmpty
                          ? SearchScreen()
                          : Container(
                        key: ValueKey(provider.currentIndex),
                        padding: const EdgeInsets.all(24),
                        color: Colors.grey.shade100,
                        child: _pages[provider.currentIndex],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // for mobile
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        titleSpacing: 0,
        flexibleSpace: const GradientBar(),
        title: Row(
          children: [
            Selector2<CategoryProvider, SearchProvider, Tuple2<String?, String>>(
              selector: (_, categoryProvider, searchProvider) =>
                  Tuple2(categoryProvider.selectedCategory, searchProvider.query),
              builder: (_, data, __) {
                final selectedCategory = data.item1;
                final query = data.item2;

                // 🔹 Search Back (highest priority)
                if (query.isNotEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: () {
                        context.read<SearchProvider>().updateQuery('');
                      },
                      child: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
                    ),
                  );
                }

                // 🔹 Category Back
                if (selectedCategory != null && selectedCategory.isNotEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: () {
                        context.read<CategoryProvider>().clearSelectedCategory();
                      },
                      child: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
                    ),
                  );
                }

                // 🔹 Nothing
                return const SizedBox.shrink();
              },
            ),
            Expanded(
              child: GestureDetector(
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SearchSuggestionPage(),
                    ),
                  );

                  if (!context.mounted) return;
                  if (result != null && result is String) {
                    context.read<SearchProvider>().updateQuery(result);
                  }
                },
                child: Container(
                  height: 45,
                  margin: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: Colors.black54),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Selector<SearchProvider, String>(
                          builder: (ctx, query, widget) {
                            return Text(
                              query.isEmpty
                                  ? 'Search for products, brands and more'
                                  : query,
                              style: TextStyle(
                                color: query.isEmpty
                                    ? Colors.grey
                                    : Colors.black87,
                                fontSize: 16,
                              ),
                              overflow: TextOverflow.ellipsis,
                            );
                          },
                          selector: (_, state) => state.query,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: Selector<SearchProvider, String>(
        builder: (_, query, __) {
          if (query.isNotEmpty) {
            return SearchScreen();
          }
          return _pages[provider.currentIndex];
        },
        selector: (_, state) => state.query,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: provider.currentIndex,
        onDestinationSelected: provider.setIndex,
        backgroundColor: Colors.white,
        indicatorColor: Colors.orange.shade100,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: "Home"),
          NavigationDestination(
            icon: Icon(Icons.category_outlined),
            label: "Categories",
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_cart_outlined),
            label: "Cart",
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: "Profile",
          ),
        ],
      ),
    );

  }
}

// 🔹 Small reusable widgets

class _TopNavIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TopNavIcon({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: isSelected ? Colors.white : Colors.white70),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryTile({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: selected ? Colors.orange.shade700 : Colors.grey.shade700,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: selected ? Colors.orange.shade700 : Colors.grey.shade800,
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: selected,
      onTap: onTap,
    );
  }
}
