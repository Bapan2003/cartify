import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../data/model/product_model.dart';
import '../data/services/product_services/firestore_services.dart';

class ProductProvider extends ChangeNotifier {
  final FirestoreService _service = FirestoreService();
  List<Product> _products = [];
  List<Product> _bannerProducts = [];
  bool _isLoading = true;
  bool _isBannerLoading = true;

  List<Product> get products => _products;
  List<Product> get bannerProducts => _bannerProducts;
  bool get isLoading => _isLoading;
  bool get isBannerLoading => _isBannerLoading;

  ProductProvider() {
    _fetchProducts();
    fetchBannerProducts();
  }

  void _fetchProducts() {
    _service.getProducts().listen((productsList) {
      _products = productsList;
      _isLoading = false;
      notifyListeners();
    });
  }

  List<Product> getByCategory(String category) {
    return _products
        .where((product) => product.category.toLowerCase() == category.toLowerCase())
        .toList();
  }


  Future<void> fetchBannerProducts() async {
    _isBannerLoading = true;
    notifyListeners();

    try {
      final snapshot =
      await FirebaseFirestore.instance.collection('products').get();

      final allProducts =
      snapshot.docs.map((doc) => Product.fromDoc(doc)).toList();

      // Pick 3 random unique products
      if (allProducts.length > 3) {
        allProducts.shuffle(Random());
        _bannerProducts
          ..clear()
          ..addAll(allProducts.take(3));
      } else {
        _bannerProducts
          ..clear()
          ..addAll(allProducts);
      }
    } catch (e) {
      debugPrint("❌ Error fetching banner products: $e");
    }

    _isBannerLoading = false;
    notifyListeners();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> fetchTrendingDeals() {
    try {
      final query = FirebaseFirestore.instance
          .collection('products')
          .where('discounted_price', isLessThan: 100000)
          .orderBy('discounted_price')
          .limit(8);

      return query.snapshots(); // 🔹 Return stream of live updates
    } catch (e) {
      debugPrint("❌ Error fetching trending deals: $e");
      rethrow;
    }
  }


  Stream<QuerySnapshot<Map<String, dynamic>>> latestArrivals(){
    try{
      final query = FirebaseFirestore.instance
          .collection('products')
          .orderBy('createdAt', descending: true)
          .limit(10);
      return query.snapshots();
    }catch(e){
      debugPrint("❌ Error fetching banner products: $e");
      rethrow;
    }
  }
}
