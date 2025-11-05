import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:qit/router/app_route.dart';

import '../data/model/cart_item_model.dart';
import '../data/model/order_model.dart';

class CheckoutProvider extends ChangeNotifier {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String get _userId => _auth.currentUser?.uid ?? '';

  int _selectedAddress = 0;
  List<CartModel> _checkoutItems = [];
  String _selectedPayment = "COD";
  bool _isFromCart=false;


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

  void setCheckoutItems(List<CartModel> items,bool isFromCart) {
    _isFromCart=isFromCart;
    _checkoutItems = items;
    notifyListeners();
  }
  String get expectedDelivery {
    final now = DateTime.now();
    final deliveryDate = now.add(const Duration(days: 5));
    return DateFormat('EEE, dd MMM yyyy').format(deliveryDate);
  }

  final List<Map<String, dynamic>> _savedAddresses = [
    {
      "name": "Sourav Yadav",
      "mobile": "+91 9876543210",
      "addressLine": "123, Lake View Road, Kolkata, WB 700091",
    },
    {
      "name": "Rohit Sharma",
      "mobile": "+91 9123456780",
      "addressLine": "45, Salt Lake Sector 5, Kolkata, WB 700102",
    },
    {
      "name": "Sherlock Holmes",
      "mobile": "+44 7712345678",
      "addressLine": "221B, Baker Street, London",
    },
    {
      "name": "Priya Sen",
      "mobile": "+91 9998877665",
      "addressLine": "Sunrise Apartment, Park Street, Kolkata, WB 700016",
    },
  ];


  List<Map<String, dynamic>> get savedAddresses => _savedAddresses;


  void updateAddress(int newAddress) {
    _selectedAddress = newAddress;
    notifyListeners();
  }

  void updatePayment(String payment) {
    _selectedPayment = payment;
    notifyListeners();
  }




  Future<void> placeOrder(BuildContext context, num deliveryCharge, ) async {
    try {
      final selectedAddressMap = _savedAddresses[_selectedAddress];

      final items = _checkoutItems.map((item) {
        return {
          "imgUrl": item.image,
          "productId": item.id,
          "productName": item.title,
          "retailPrice": item.discountedPrice,
          "quantity": item.quantity,
        };
      }).toList();

      final bill = {
        "item_total": subTotal,
        "delivery": deliveryCharge,
        "platform_fee": platformFee,
        "free_delivery": true,
        "order_total": total,
      };

      final order = {
        "address": selectedAddressMap,
        "payment": _selectedPayment,
        "delivery_date":
        DateTime.now().add(const Duration(days: 5)).toIso8601String(),
        "created_at": DateTime.now().toIso8601String(),
        "items": items,
        "bill": bill,
        "status": "Placed",
      };

      // 🔹 Save to Firestore
      final orderDoc =
      await _firestore.collection('users').doc(_userId).collection('orders').add(order);

      debugPrint("✅ Order saved to Firestore with ID: ${orderDoc.id}");
      debugPrint(jsonEncode(order));


      if(_isFromCart){
        final cartRef = _firestore.collection('users').doc(_userId).collection('cart');
        final cartSnapshot = await cartRef.get();
        for (var doc in cartSnapshot.docs) {
          await doc.reference.delete();
        }
      }
      if(!context.mounted)return;
      // Navigate to success page
      context.pushReplacement(AppRoute.checkoutSuccess);
    } catch (e) {
      debugPrint("❌ Failed to place order: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to place order: $e")),
      );
    }

  }



}
