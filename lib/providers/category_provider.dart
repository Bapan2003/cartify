import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../data/model/product_model.dart';

class CategoryProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<String> _categories = [];
  List<String> get categories => _categories;

  String? _selectedCategory;
  String? get selectedCategory => _selectedCategory;

  List<Product> _categoryProducts = [];
  List<Product> get categoryProducts => _categoryProducts;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  CategoryProvider() {
    fetchCategories();
  }

  /// ✅ Fetch unique category names
  Future<void> fetchCategories() async {
    _isLoading = true;
    notifyListeners();
    try {
      final snapshot = await _firestore.collection('products').get();
      final uniqueCategories = snapshot.docs
          .map((doc) => (doc['category'] ?? '').toString())
          .where((c) => c.isNotEmpty)
          .toSet()
          .toList();

      _categories = uniqueCategories;
    } catch (e) {
      debugPrint("Error loading categories: $e");
    }
    _isLoading = false;
    notifyListeners();
  }

  /// ✅ Fetch products by category
  Future<void> fetchProductsByCategory(String category) async {
    _isLoading = true;
    notifyListeners();
    try {
      _selectedCategory = category;
      final snapshot = await _firestore
          .collection('products')
          .where('category', isEqualTo: category)
          .limit(30)
          .get();

      _categoryProducts = snapshot.docs.map((e) => Product.fromDoc(e)).toList();
    } catch (e) {
      debugPrint("Error fetching category products: $e");
    }
    _isLoading = false;
    notifyListeners();
  }

  void clearSelectedCategory() {
    _selectedCategory = null;
    notifyListeners();
  }
}
