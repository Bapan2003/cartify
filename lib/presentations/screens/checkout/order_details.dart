import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:qit/providers/profile_provider.dart';

import '../../../core/app_helper.dart';
import '../../../data/model/order_model.dart';
import '../../widgets/gradient_bar.dart';


class OrderDetailsScreen extends StatelessWidget {
  const OrderDetailsScreen({super.key, });

  @override
  Widget build(BuildContext context) {
    final order=context.read<ProfileProvider>().selectedOrder!;
    final isIOS = defaultTargetPlatform == TargetPlatform.iOS;
    final isWeb = MediaQuery.of(context).size.width > 900;



    final baseStyle = Theme.of(context)
        .textTheme
        .titleMedium!
        .copyWith(color: Colors.black87);


    DateTime deliveryDate;

    try {
      deliveryDate = DateTime.tryParse(order.deliveryDate) ?? DateTime.now();
    } catch (e) {
      debugPrint("❌ Error parsing date: $e");
      deliveryDate = DateTime.now();
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final deliveryDay = DateTime(deliveryDate.year, deliveryDate.month, deliveryDate.day);

    final diffDays = deliveryDay.difference(today).inDays;
    final formattedDate = DateFormat("dd MMM, yyyy").format(deliveryDate);

    String deliveryText;
    final title = diffDays < 0 ? "Delivered to" : "Delivering to";
    IconData icon;
    Color color;

    if (diffDays < 0) {
      deliveryText = "Delivered on $formattedDate";
      icon = Icons.check_circle_outline;
      color = Colors.green;
    } else if (diffDays == 0) {
      deliveryText = "Expected delivery: Today";
      icon = Icons.local_shipping_outlined;
      color = Colors.orange;
    } else if (diffDays == 1) {
      deliveryText = "Expected delivery: Tomorrow";
      icon = Icons.local_shipping_outlined;
      color = Colors.orange;
    } else {
      deliveryText = "Expected delivery: $formattedDate";
      icon = Icons.local_shipping_outlined;
      color = Colors.orange;
    }
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
          Text("Order Summary",
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),

          // 🔹 Show ordered items
          for (var item in order.items)
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding:
              const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
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
                      item['imgUrl'],
                      height: 55,
                      width: 55,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const SizedBox(
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
                          item['productName'],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Qty: ${item['quantity']} • ₹${AppHelper.formatAmount(item['retailPrice'].toString())}",
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
                    "₹${AppHelper.formatAmount((item['retailPrice'] * item['quantity']).toStringAsFixed(2))}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

          const Divider(height: 24),
          _rowText("Items:", "₹${AppHelper.formatAmount(order.bill['item_total'].toString())}", baseStyle),
          _rowText("Delivery:", "₹${AppHelper.formatAmount(order.bill['delivery'].toString())}", baseStyle),
          _rowText("Platform Fee:", "₹${AppHelper.formatAmount(order.bill['platform_fee'].toString())}", baseStyle),
          _rowText(
            "Free Delivery:",
            "-₹${AppHelper.formatAmount(order.bill['delivery'].toString())}",
            baseStyle.copyWith(
              color: Colors.green.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order Total:',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge!
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                '₹${AppHelper.formatAmount(order.bill['order_total'].toString())}',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge!
                    .copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );

    // 🏠 Address + Payment + Delivery Section
    Widget buildLeftContent() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text('Order Details',style: TextStyle(fontSize: 22,fontWeight: FontWeight.w500),),
        ),
        Text(
          "$title ${order.address['name']}",
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
                  "${order.address['addressLine']}\n${order.address['mobile']}",
                  style: const TextStyle(fontSize: 15),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text("Payment Method",
            style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey.shade100,
          ),
          child: Text(
            order.payment.toUpperCase(),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
             Icon(icon, color: color),
            const SizedBox(width: 8),
            Text(
              deliveryText,
              style:
              const TextStyle(fontSize: 15, color: Colors.black87),
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
          Expanded(flex: 2, child: buildLeftContent()),
          const SizedBox(width: 5),
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
      child: SafeArea(child: body),
    )
        : Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(child: body),
    );
  }

  // Helper for row text pairs
  Widget _rowText(String label, String value, TextStyle style) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label, style: style), Text(value, style: style)],
      ),
    );
  }


}
