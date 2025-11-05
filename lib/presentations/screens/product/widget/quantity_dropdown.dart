import 'package:flutter/material.dart';

class QuantityDropdown extends StatelessWidget {
  final int maxQuantity;
  final ValueNotifier<int> selectedQtyNotifier;

  const QuantityDropdown({
    super.key,
    required this.maxQuantity,
    required this.selectedQtyNotifier,
  });

  @override
  Widget build(BuildContext context) {
    final availableQty = maxQuantity > 10 ? 10 : maxQuantity; // show max 10 in dropdown

    return ValueListenableBuilder<int>(
      valueListenable: selectedQtyNotifier,
      builder: (context, selectedQty, _) {
        return DropdownButtonFormField<int>(
          value: selectedQty,
          onChanged: (value) {
            if (value != null) selectedQtyNotifier.value = value;
          },
          items: List.generate(
            availableQty,
                (index) => DropdownMenuItem<int>(
              value: index + 1,
              child: Text('Qty: ${index + 1}'),
            ),
          ),
          decoration: InputDecoration(
            labelText: "Quantity",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          ),
        );
      },
    );
  }
}
