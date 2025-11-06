import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WishlistProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _wishlistCollection = 'wishlists';

  List<String> _wishlistItems = [];
  List<String> get wishlistItems => _wishlistItems;



  String get userId => FirebaseAuth.instance.currentUser?.uid ?? '';

  Stream<List<String>> wishlistStream() {
    if (userId.isEmpty) return const Stream.empty();

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('wishlist')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.id).toList());
  }

  /// Add a product to wishlist
  Future<void> addToWishlist(String productId) async {
    if (userId.isEmpty) return;

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('wishlist')
        .doc(productId)
        .set({
      'addedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Remove a product from wishlist
  Future<void> removeFromWishlist(String productId) async {
    if (userId.isEmpty) return;

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('wishlist')
        .doc(productId)
        .delete();
  }

  bool isInWishlist(String productId) {
    return _wishlistItems.contains(productId);
  }
}
