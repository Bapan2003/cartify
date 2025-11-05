import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:qit/core/app_helper.dart';

import 'package:qit/presentations/widgets/gradient_bar.dart';

import '../../../providers/checkout_provider.dart';
import '../../../router/app_route.dart';
import '../cart/widget/cart_item.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CheckoutProvider>();
    final isIOS = defaultTargetPlatform == TargetPlatform.iOS;
    final isWeb = MediaQuery.of(context).size.width > 900;

    final baseStyle = Theme.of(
      context,
    ).textTheme.titleMedium!.copyWith(color: Colors.black87);

    final deliveryCharge = provider.subTotal * 0.05;
    final cappedDelivery = deliveryCharge.clamp(40, 200);
    final totalWithDelivery = provider.subTotal + cappedDelivery + 5;
    final freeDelivery = cappedDelivery;
    final orderTotal = totalWithDelivery - freeDelivery;

    // 🧾 Reusable Order Summary Widget
    Widget buildOrderSummary() => Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Order Summary", style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          for (var item in provider.checkoutItems)
            InkWell(
              onTap: () => context.pushNamed(
                AppRoute.productDetails,
                queryParameters: {'productId': item.id},
              ),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🖼️ Product image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        item.image,
                        height: 55,
                        width: 55,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => SizedBox(
                          height: 55,
                          width: 55,
                          child: Icon(Icons.error),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // 📝 Product info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Qty: ${item.quantity} • ₹${AppHelper.formatAmount(item.discountedPrice.toStringAsFixed(2))}",
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 💰 Price
                    Text(
                      "₹${AppHelper.formatAmount((item.discountedPrice * item.quantity).toStringAsFixed(2))}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Items:', style: baseStyle),
              Text(
                '₹${AppHelper.formatAmount(provider.subTotal.toStringAsFixed(2))}',
                style: baseStyle.copyWith(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Delivery:', style: baseStyle),
              Text('₹${AppHelper.formatAmount(cappedDelivery.toStringAsFixed(2))}', style: baseStyle),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Platform Fee:', style: baseStyle),
              const Text('₹5'),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Free Delivery:', style: baseStyle),
              Text(
                '-₹${AppHelper.formatAmount(freeDelivery.toStringAsFixed(2))}',
                style: baseStyle.copyWith(
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order Total:',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                '₹${AppHelper.formatAmount(orderTotal.toStringAsFixed(2))}',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: isIOS
                ? CupertinoButton(
                    borderRadius: BorderRadius.circular(10),
                    color: const Color(0xFFFFA41C),
                    // Amazon-like orange
                    padding: const EdgeInsets.symmetric(vertical: 14),
              onPressed: () => provider.placeOrder(context,freeDelivery,),
                    child: const Text(
                      "Place Order",
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
                    onPressed: () => provider.placeOrder(context,freeDelivery,),
                    child: Text(
                      "Place Order",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );

    // 🏠 Address + Payment + Delivery Section
    Widget buildLeftContent() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Delivering to ${provider.savedAddresses[provider.selectedAddress]['name']}",
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey.shade100,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.location_on, color: Colors.red),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  provider.savedAddresses[provider
                      .selectedAddress]['addressLine'],
                  style: const TextStyle(fontSize: 15),
                ),
              ),
              GestureDetector(
                onTap: () => _showAddressBottomSheet(context),
                child: const Text(
                  "Change",
                  style: TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text("Payment Method", style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        RadioListTile<String>(
          title: const Text("Cash on Delivery (COD)"),
          value: "COD",
          groupValue: provider.selectedPayment,
          onChanged: (newValue) {
            if (newValue != null) {
              provider.updatePayment(newValue);
            }
          },
        ),
        RadioListTile<String>(
          title: const Text("Pay by UPI"),
          value: "UPI",
          groupValue: provider.selectedPayment,
          onChanged: (newValue) {
            if (newValue != null) {
              provider.updatePayment(newValue);
            }
          },
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            const Icon(Icons.local_shipping_outlined, color: Colors.green),
            const SizedBox(width: 8),
            Text(
              "Expected delivery: ${provider.expectedDelivery}",
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            ),
          ],
        ),
      ],
    );

    // 🌐 Responsive Layout
    final body = isWeb
        ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🏠 LEFT CONTENT (Address + Payment)
                Expanded(flex: 2, child: buildLeftContent()),

                const SizedBox(width: 5),
                // 🧾 RIGHT CONTENT (Order Summary) — scrollable separately
                Expanded(
                  flex: 1,
                  child: CustomScrollView(
                    slivers: [SliverToBoxAdapter(child: buildOrderSummary())],
                  ),
                ),
              ],
            ),
          )
        : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildLeftContent(),
                  const SizedBox(height: 30),
                  buildOrderSummary(),
                ],
              ),
            ),
          );

    return isIOS
        ? CupertinoPageScaffold(
            navigationBar: const CupertinoNavigationBar(
              middle: Text("Checkout"),
            ),
            child: SafeArea(child: body),
          )
        : Scaffold(
            backgroundColor: Colors.grey.shade50,
            appBar: AppBar(
              flexibleSpace: const GradientBar(),
              title: const Text('Confirm Order'),
            ),
            body: SafeArea(child: body),
          );
  }

  void _showAddressBottomSheet(BuildContext context) {
    final provider = context.read<CheckoutProvider>();
    final isIOS = defaultTargetPlatform == TargetPlatform.iOS;

    if (isIOS) {
      // 🔹 Cupertino (iOS) Style Bottom Sheet
      showCupertinoModalPopup(
        context: context,
        builder: (_) => CupertinoActionSheet(
          title: const Text("Select Delivery Address"),
          actions: provider.savedAddresses.map((address) {
            final isSelected =
                address == provider.savedAddresses[provider.selectedAddress];
            return CupertinoActionSheetAction(
              onPressed: () {
                provider.updateAddress(
                  provider.savedAddresses.indexOf(address),
                );
                Navigator.pop(context);
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    address['name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.black,
                    ),
                  ),
                  Text(
                    address['mobile'],
                    style: const TextStyle(color: CupertinoColors.systemGrey),
                  ),
                  Text(
                    address['addressLine'],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isSelected
                          ? CupertinoColors.activeOrange
                          : CupertinoColors.black,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  if (isSelected)
                    const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Icon(
                        CupertinoIcons.check_mark_circled_solid,
                        size: 20,
                        color: CupertinoColors.activeGreen,
                      ),
                    ),
                ],
              ),
            );
          }).toList(),
        ),
      );
    } else {
      // 🔹 Material (Android/Web) Style Bottom Sheet
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (_) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Select Delivery Address",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),

                // 🔹 List of Saved Addresses
                ...provider.savedAddresses.map((address) {
                  final isSelected =
                      address ==
                      provider.savedAddresses[provider.selectedAddress];

                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? Colors.orange
                            : Colors.grey.shade300,
                        width: isSelected ? 2 : 1,
                      ),
                      color: isSelected
                          ? Colors.orange.shade50
                          : Colors.grey.shade100,
                    ),
                    child: ListTile(
                      leading: const Icon(
                        Icons.location_on_outlined,
                        color: Colors.red,
                      ),
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            address['name'],
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            address['mobile'],
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            address['addressLine'],
                            style: TextStyle(
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      trailing: isSelected
                          ? const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 22,
                            )
                          : null,
                      onTap: () {
                        provider.updateAddress(
                          provider.savedAddresses.indexOf(address),
                        );
                        Navigator.pop(context);
                      },
                    ),
                  );
                }).toList(),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      );
    }
  }
}

class _BillRow extends StatelessWidget {
  final String title;
  final String value;
  final bool isBold;

  const _BillRow({
    required this.title,
    required this.value,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            '${value.toLowerCase() == 'free' ? '' : '₹'}$value',
            style: TextStyle(
              fontSize: 15,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
