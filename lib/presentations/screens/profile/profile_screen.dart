import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qit/core/app_helper.dart';
import 'package:qit/providers/checkout_provider.dart';
import 'package:qit/providers/dashboard_provider.dart';
import 'package:qit/providers/product_provider.dart';
import 'package:qit/providers/profile_provider.dart';
import 'package:qit/router/app_route.dart';

import '../../../data/model/order_model.dart';
import '../../../providers/auth_providers.dart';
import '../../../providers/wishlist_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final ValueNotifier<bool> _isChanged = ValueNotifier(false);
  final ValueNotifier<bool> _isLoading = ValueNotifier(false);
  File? _newProfileImage;
  late Map<String, dynamic> _initialData;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _isChanged.dispose();
    _isLoading.dispose();
    super.dispose();
  }

  void _checkChanges() {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final initialName = _initialData['name'] ?? '';
    final initialPhone = _initialData['phone'] ?? '';
    final hasChanged =
        name != initialName ||
        phone != initialPhone ||
        _newProfileImage != null;

    if (_isChanged.value != hasChanged) _isChanged.value = hasChanged;
  }

  void _showProfileBottomSheet(
    BuildContext context,
    Map<String, dynamic> userData,
    AuthProvider auth,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundImage: userData['photoUrl'] != null
                        ? NetworkImage(userData['photoUrl'])
                        : null,
                    child: userData['photoUrl'] == null
                        ? const Icon(Icons.person, size: 28)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      userData['name'] ?? '',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.email, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Signed in as ${userData['email'] ?? ''}",
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await auth.signOut();
                  if (context.mounted) context.go('/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFA41C),
                  // Amazon orange
                  foregroundColor: Colors.white,
                  shadowColor: Colors.orangeAccent.withOpacity(0.4),
                  elevation: 3,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  minimumSize: const Size.fromHeight(50),
                ),
                child: const Text("Sign Out"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final size = MediaQuery.of(context).size;
    final isWeb = kIsWeb && size.width > 800;
    return Scaffold(
      backgroundColor: isWeb ? Colors.grey[100] : null,
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: auth.getUserDataStream(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("No profile data found."));
          }

          final userData = snapshot.data!.data()!;
          _initialData = userData;
          _nameController.text = userData['name'] ?? '';
          _phoneController.text = userData['phone'] ?? '';

          _nameController.removeListener(_checkChanges);
          _phoneController.removeListener(_checkChanges);
          _nameController.addListener(_checkChanges);
          _phoneController.addListener(_checkChanges);

          final fullName = userData['name'] ?? '';
          final firstWord = fullName.split(' ').first;
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Top Row: Avatar + Hello + Dropdown + Spacer + Settings + Logout
                    InkWell(
                      onTap: () =>
                          _showProfileBottomSheet(context, userData, auth),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundImage: userData['photoUrl'] != null
                                ? NetworkImage(userData['photoUrl'])
                                : null,
                            child: userData['photoUrl'] == null
                                ? const Icon(Icons.person, size: 28)
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Row(
                              children: [
                                Text(
                                  "Hello, $firstWord",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.arrow_drop_down),
                                  onPressed: () => _showProfileBottomSheet(
                                    context,
                                    userData,
                                    auth,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (!isWeb)
                            IconButton(
                              icon: const Icon(Icons.settings),
                              onPressed: () {
                                context.push(AppRoute.editProfile);
                              },
                            ),
                          IconButton(
                            icon: const Icon(Icons.logout),
                            onPressed: () async {
                              await auth.signOut();
                              if (context.mounted) context.go('/login');
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    /// Wishlist Section
                    _buildWishlistSection(),

                    const SizedBox(height: 24),

                    /// Orders Section
                    StreamBuilder<List<OrderModel>>(
                      stream: context.read<ProfileProvider>().getUserOrders(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (snapshot.hasError) {
                          return Center(
                            child: Text("Error: ${snapshot.error}"),
                          );
                        }
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return  Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              "No orders yet.",
                              textAlign: TextAlign.start,
                              style: TextStyle(color: Colors.grey),
                            ),
                          );
                        }

                        final orders = snapshot.data!.where((order) {
                          DateTime? deliveryDate;

                          // Handle both Timestamp and String types
                          if (order.deliveryDate is Timestamp) {
                            deliveryDate = (order.deliveryDate as Timestamp).toDate();
                          } else if (order.deliveryDate is String) {
                            try {
                              deliveryDate = DateTime.parse(order.deliveryDate);
                            } catch (_) {
                              return false; // invalid format, skip
                            }
                          }

                          // Keep only if deliveryDate is today or later
                          return deliveryDate != null &&
                              deliveryDate.isAfter(DateTime.now().subtract(const Duration(days: 1)));
                        }).toList();
                        return _buildOrdersSection(orders);
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWishlistSection() {
    return Consumer<WishlistProvider>(
      builder: (context, wishlistProvider, _) {
        final wishlistItems = wishlistProvider.wishlistItems;
        final itemCount = wishlistItems.length;

        if (itemCount == 0) {
          return const SizedBox.shrink();
        }

        final firstTwoIds = wishlistItems.take(3).toList();
        final remainingCount = itemCount - firstTwoIds.length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Saved Products",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () => context.read<DashboardProvider>().setIndex(4),
              child: Container(
                padding: const EdgeInsets.all(12), // optional padding inside
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400, width: 1),
                  // border
                  borderRadius: BorderRadius.circular(8), // rounded corners
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ...firstTwoIds.map(
                      (id) => FutureBuilder<Map<String, dynamic>?>(
                        future: context
                            .read<ProductProvider>()
                            .fetchProductById(id),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Container(
                              width: 65,
                              height: 65,
                              color: Colors.grey.shade200,
                              margin: const EdgeInsets.only(right: 8),
                            );
                          }
                          final product = snapshot.data!;
                          final imageUrl = product['images'][0] ?? '';
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                imageUrl,
                                width: 70,
                                height: 70,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => SizedBox(
                                  width: 70,
                                  height: 70,
                                  child: Icon(Icons.error),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // show remaining count if more than 2 products
                    if (remainingCount > 0)
                      Container(
                        width: 65,
                        height: 65,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '+$remainingCount',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildOrdersSection(List<OrderModel> orders) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "My Orders",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        if (orders.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              "No orders yet.",
              textAlign: TextAlign.start,
              style: TextStyle(color: Colors.grey),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: const Icon(
                    Icons.shopping_bag_outlined,
                    color: Colors.orange,
                  ),
                  title: Text("Order #${order.id.toString().substring(0,10)}...", ),
                  subtitle: Text(
                    "${order.address['name']} • ${AppHelper.formatDate(order.deliveryDate)}\n${order.items.length} items — ₹${AppHelper.formatAmount(order.bill['order_total'].toString())}",
                  ),
                  isThreeLine: true,
                  trailing: Text(
                    order.payment=='COD'?'Cash on Delivery':'Pay by UPI',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}

/// ✅ Utility: Combine two ValueListenables in one builder
class ValueListenableBuilder2<A, B> extends StatelessWidget {
  final ValueListenable<A> first;
  final ValueListenable<B> second;
  final Widget Function(BuildContext, A, B, Widget?) builder;
  final Widget? child;

  const ValueListenableBuilder2({
    super.key,
    required this.first,
    required this.second,
    required this.builder,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<A>(
      valueListenable: first,
      builder: (ctx, a, _) {
        return ValueListenableBuilder<B>(
          valueListenable: second,
          builder: (ctx, b, __) => builder(ctx, a, b, child),
        );
      },
    );
  }
}
