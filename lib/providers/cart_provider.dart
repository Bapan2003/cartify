import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qit/data/model/cart_item_model.dart';
import '../data/model/product_model.dart';

class CartProvider extends ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String get _userId => _auth.currentUser?.uid ?? '';

  CartProvider() {
    listenToCartChanges();
  }

  List<CartModel> _cartItems = [];
  List<CartModel> get cartItems => _cartItems;

  double get totalPrice =>
      _cartItems.fold(0, (sum, item) => sum + item.discountedPrice * item.quantity);

  void listenToCartChanges() {
    _firestore
        .collection('users')
        .doc(_userId)
        .collection('cart')
        .snapshots()
        .listen((snapshot) {
      _cartItems = snapshot.docs.map((doc) => CartModel.fromMap(doc.data(),doc.id)).toList();
      notifyListeners();
    });
  }

  Future<void> addToCart(CartModel cartModel) async {
    final ref = _firestore.collection('users').doc(_userId).collection('cart').doc(cartModel.id);
    await ref.set(cartModel.toMap());
  }

  Future<void> removeFromCart(CartModel cartModel) async {
    await _firestore.collection('users').doc(_userId).collection('cart').doc(cartModel.id).delete();
  }

  Future<void> updateQuantity(CartModel cartModel, int qty) async {
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('cart')
        .doc(cartModel.id)
        .update({'quantity': qty});
  }
}
