import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/model/cart_item_model.dart';

class CheckoutProvider extends ChangeNotifier {
  int _selectedAddress = 0;
  List<CartModel> _checkoutItems = [];
  String _selectedPayment = "COD";

  int get selectedAddress => _selectedAddress;
  String get selectedPayment => _selectedPayment;
  List<CartModel> get checkoutItems => _checkoutItems;

  double get subTotal =>
      _checkoutItems.fold(0, (sum, item) => sum + (item.discountedPrice * item.quantity));

  double get platformFee => 5.0;

  double get total => subTotal + platformFee;

  void addBuyNowItem(CartModel product) {
    _checkoutItems = [product];
    notifyListeners();
  }

  void setCheckoutItems(List<CartModel> items) {
    _checkoutItems = items;
    notifyListeners();
  }
  String get expectedDelivery {
    final now = DateTime.now();
    final deliveryDate = now.add(const Duration(days: 5));
    return DateFormat('EEE, dd MMM yyyy').format(deliveryDate);
  }

  final List<String> _savedAddresses = [
    "123, Lake View Road, Kolkata, WB 700091",
    "45, Salt Lake Sector 5, Kolkata, WB 700102",
    "221B, Baker Street, London",
    "Sunrise Apartment, Park Street, Kolkata, WB 700016",
  ];

  List<String> get savedAddresses => _savedAddresses;


  void updateAddress(int newAddress) {
    _selectedAddress = newAddress;
    notifyListeners();
  }

  void updatePayment(String payment) {
    _selectedPayment = payment;
    notifyListeners();
  }

  void placeOrder() {
    // TODO: Add your Firebase order placement logic here
    debugPrint("✅ Order placed successfully with $_selectedPayment");
  }
}
