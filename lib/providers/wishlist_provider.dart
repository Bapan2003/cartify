import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/foundation.dart';

class WishlistProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<String> _wishlistItems = [];
  List<String> get wishlistItems => _wishlistItems;

  WishlistProvider() {
    _listenWishlist(); // Start listening to real-time updates
  }

  String get userId => FirebaseAuth.instance.currentUser?.uid ?? '';

  /// Listen to Firestore changes in real-time
  void _listenWishlist() {
    if (userId.isEmpty) return;

    _firestore
        .collection('users')
        .doc(userId)
        .collection('wishlist')
        .snapshots()
        .listen((snapshot) {
      _wishlistItems = snapshot.docs.map((doc) => doc.id).toList();
      notifyListeners();
    });
  }



  /// Add a product to wishlist
  Future<void> addToWishlist(String productId) async {
    if (userId.isEmpty) return;

    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('wishlist')
          .doc(productId)
          .set({'addedAt': FieldValue.serverTimestamp()});

      // Update local list immediately
      if (!_wishlistItems.contains(productId)) {
        _wishlistItems.add(productId);
        notifyListeners();
      }
    } catch (e) {
      print('Error adding to wishlist: $e');
    }
  }

  /// Remove a product from wishlist
  Future<void> removeFromWishlist(String productId) async {
    if (userId.isEmpty) return;

    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('wishlist')
          .doc(productId)
          .delete();

      // Update local list immediately
      _wishlistItems.remove(productId);
      notifyListeners();
    } catch (e) {
      print('Error removing from wishlist: $e');
    }
  }

  /// Check if a product is in wishlist
  bool isInWishlist(String productId) {
    return _wishlistItems.contains(productId);
  }

  /// Stream for UI widgets if needed
  Stream<List<String>> wishlistStream() {
    if (userId.isEmpty) return const Stream.empty();

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('wishlist')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.id).toList());
  }
}
