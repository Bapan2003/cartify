import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SearchProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<String> selectedFilters = [];
  String _query = '';
  String get query => _query;

  List<QueryDocumentSnapshot> _allProducts = [];
  List<QueryDocumentSnapshot> _filteredProducts = [];
  List<QueryDocumentSnapshot> _queryResult = [];
  List<QueryDocumentSnapshot> get filteredProducts => _filteredProducts;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  SearchProvider() {
    _fetchProducts();
  }

  void toggleFilter(String filter) {
    if (selectedFilters.contains(filter)) {
      selectedFilters.remove(filter);
    } else {
      selectedFilters.add(filter);
    }
    applyFilters();
    notifyListeners();
  }
  void applyFilters() {
    // Start fresh with full product list
    _filteredProducts = List.from(_queryResult);

    for (final filter in selectedFilters) {
      switch (filter) {
      // 🟢 Free Shipping
        case 'Free Shipping':
          _filteredProducts = _filteredProducts
              .where((p) => (p['shipping_type'] ?? '').toLowerCase().contains('free'))
              .toList();
          break;

      // 🟠 Paid Shipping
        case 'Paid Shipping':
          _filteredProducts = _filteredProducts
              .where((p) => (p['shipping_type'] ?? '').toLowerCase().contains('paid'))
              .toList();
          break;

      // 🍎 iPhone or Brand Filter
        case 'iPhone':
          _filteredProducts = _filteredProducts
              .where((p) => (p['product_name'] ?? '').toString().toLowerCase().contains('iphone'))
              .toList();
          break;

      // 💸 All Discounts (any discounted price less than retail)
        case 'All Discounts':
          _filteredProducts = _filteredProducts
              .where((p) {
            final original = (p['retail_price'] ?? 0).toDouble();
            final discounted = (p['discounted_price'] ?? 0).toDouble();
            return discounted < original;
          })
              .toList();
          break;

      // 🔟 10% off or more
        case '10% off or more':
          _filteredProducts = _filteredProducts.where((p) {
            final original = (p['retail_price'] ?? 0).toDouble();
            final discounted = (p['discounted_price'] ?? 0).toDouble();
            if (original <= 0) return false;
            final discountPercent = ((original - discounted) / original) * 100;
            return discountPercent >= 10;
          }).toList();
          break;

      // 🟣 25% off or more
        case '25% off or more':
          _filteredProducts = _filteredProducts.where((p) {
            final original = (p['retail_price'] ?? 0).toDouble();
            final discounted = (p['discounted_price'] ?? 0).toDouble();
            if (original <= 0) return false;
            final discountPercent = ((original - discounted) / original) * 100;
            return discountPercent >= 25;
          }).toList();
          break;

      // 🟤 Include Out of Stock
        case 'Include Out of Stock':
        // Do nothing (include all items)
          break;

      // 💥 Value Pick = Products with highest total_bought
        case 'Value Pick':
          _filteredProducts.sort((a, b) {
            final boughtA = (a['total_buy'] ?? 0) as int;
            final boughtB = (b['total_buy'] ?? 0) as int;
            return boughtB.compareTo(boughtA); // Descending order
          });
          // Optionally, only keep top 10
          _filteredProducts = _filteredProducts.take(10).toList();
          break;
      }
    }
  }




  /// 🔹 Listen to product changes in Firestore
  void _fetchProducts() {
    _firestore
        .collection('products')
        .orderBy('product_name')
        .snapshots()
        .listen((snapshot) {
      _allProducts = snapshot.docs;
      _applyQuery();
      _isLoading = false;
      notifyListeners();
    });
  }

  /// 🔹 Update search query and re-filter products
  void updateQuery(String value) {
    _query = value.trim().toLowerCase();
    _applyQuery();
    applyFilters();
    notifyListeners();
  }

  /// 🔹 Apply local filtering to cached Firestore data
  void _applyQuery() {
    if (_query.isEmpty) {
      _queryResult = _allProducts;
    } else {
      _queryResult = _allProducts.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final name = (data['product_name'] ?? '').toString().toLowerCase();
        final brand = (data['brand'] ?? '').toString().toLowerCase();
        final category = (data['category'] ?? '').toString().toLowerCase();

        return name.contains(_query) ||
            brand.contains(_query) ||
            category.contains(_query);
      }).toList();
    }
  }

  /// 🔹 Force refresh from Firestore manually (optional)
  Future<void> refresh() async {
    _isLoading = true;
    notifyListeners();

    final snapshot = await _firestore
        .collection('products')
        .orderBy('product_name')
        .get();

    _allProducts = snapshot.docs;
    _applyQuery();
    _isLoading = false;
    notifyListeners();
  }
}

