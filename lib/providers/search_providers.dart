import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SearchProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Filters
  String? selectedShipping; // 'Free' or 'Paid'
  List<String> selectedDiscounts = []; // ['10%', '25%']
  List<String> selectedBrands = [];
  List<String> selectedCategories = [];
  List<String> brands = [];
  List<String> categories = [];
  bool valuePick = false;

  // Sort By options
  String sortBy = 'Latest'; // Default sort

  String _query = '';
  String get query => _query;

  List<QueryDocumentSnapshot> _allProducts = [];
  List<QueryDocumentSnapshot> _filteredProducts = [];
  List<QueryDocumentSnapshot> _queryResult = [];
  List<QueryDocumentSnapshot> get queryResult => _queryResult;
  List<QueryDocumentSnapshot> get filteredProducts => _filteredProducts;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  SearchProvider() {
    _fetchProducts();
  }

  /// 🔹 Update query
  void updateQuery(String value) {
    _query = value.trim().toLowerCase();
    _queryBasedSearch();
    _applyFiltersAndSort();
    notifyListeners();
  }

  /// 🔹 Set shipping filter (single choice)
  void setShipping(String? shipping) {
    selectedShipping = shipping;
    _applyFiltersAndSort();
    notifyListeners();
  }

  /// 🔹 Toggle discount filter (multi-select)
  void toggleDiscount(String discount) {
    if (selectedDiscounts.contains(discount)) {
      selectedDiscounts.remove(discount);
    } else {
      selectedDiscounts.add(discount);
    }
    _applyFiltersAndSort();
    notifyListeners();
  }

  /// 🔹 Toggle brand filter (multi-select)
  void toggleBrand(String brand) {
    if (selectedBrands.contains(brand)) {
      selectedBrands.remove(brand);
    } else {
      selectedBrands.add(brand);
    }
    _applyFiltersAndSort();
    notifyListeners();
  }

  /// 🔹 Toggle category filter (multi-select)
  void toggleCategory(String category) {
    if (selectedCategories.contains(category)) {
      selectedCategories.remove(category);
    } else {
      selectedCategories.add(category);
    }
    _applyFiltersAndSort();
    notifyListeners();
  }

  /// 🔹 Toggle value pick
  void toggleValuePick() {
    valuePick = !valuePick;
    _applyFiltersAndSort();
    notifyListeners();
  }

  void setSortBy(String option) {
    sortBy = option;
    _applyFiltersAndSort();
    notifyListeners();
  }

  void clearFilters() {
    selectedShipping = null;
    selectedDiscounts.clear();
    selectedBrands.clear();
    selectedCategories.clear();
    valuePick = false;
    _applyFiltersAndSort();
    notifyListeners();
  }

  /// 🔹 Core function: apply query → filters → sort
  void _applyFiltersAndSort() {
    List<QueryDocumentSnapshot> temp = List.from(_allProducts);

    // 1️⃣ Apply query if non-empty
    if (_query.isNotEmpty) {
      temp = temp.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final name = (data['product_name'] ?? '').toString().toLowerCase();
        final brand = (data['brand'] ?? '').toString().toLowerCase();
        final category = (data['category'] ?? '').toString().toLowerCase();
        return name.contains(_query) ||
            brand.contains(_query) ||
            category.contains(_query);
      }).toList();
    }

    // 2️⃣ Apply filters
    if (selectedShipping != null) {
      temp = temp.where((doc) {
        final shipping = (doc['shipping_type'] ?? '').toString().toLowerCase();
        return shipping == selectedShipping!.toLowerCase();
      }).toList();
    }
    if (selectedDiscounts.isNotEmpty) {
      temp = temp.where((doc) {
        final original = (doc['retail_price'] ?? 0).toDouble();
        final discounted = (doc['discounted_price'] ?? 0).toDouble();
        if (original <= 0) return false;

        final discountPercent = ((original - discounted) / original) * 100;

        // If "All" is selected, include any product with a discount
        if (selectedDiscounts.contains('All') && discountPercent > 0) {
          return true;
        }

        // Otherwise, match specific discount percentages
        for (var d in selectedDiscounts) {
          if (d == 'All') continue; // skip "All" since already handled
          final percentString = d.replaceAll('%', '');
          final percent = int.tryParse(percentString);
          if (percent != null && discountPercent >= percent) return true;
        }

        return false;
      }).toList();
    }



    if (selectedBrands.isNotEmpty) {
      temp = temp.where((doc) {
        final brand = (doc['brand'] ?? '').toString();
        return selectedBrands.contains(brand);
      }).toList();
    }

    if (selectedCategories.isNotEmpty) {
      temp = temp.where((doc) {
        final category = (doc['category'] ?? '').toString();
        return selectedCategories.contains(category);
      }).toList();
    }

    // 3️⃣ Value Pick
    if (valuePick) {
      temp.sort((a, b) {
        final boughtA = (a['total_buy'] ?? 0) as int;
        final boughtB = (b['total_buy'] ?? 0) as int;
        return boughtB.compareTo(boughtA);
      });
    }

    // 4️⃣ Apply sort
    switch (sortBy) {
      case 'Low to High':
        temp.sort((a, b) =>
            (a['discounted_price'] ?? 0).toDouble().compareTo(
                (b['discounted_price'] ?? 0).toDouble()));
        break;
      case 'High to Low':
        temp.sort((a, b) =>
            (b['discounted_price'] ?? 0).toDouble().compareTo(
                (a['discounted_price'] ?? 0).toDouble()));
        break;
      case 'A to Z':
        temp.sort((a, b) => (a['product_name'] ?? '')
            .toString()
            .compareTo((b['product_name'] ?? '').toString()));
        break;
      case 'Z to A':
        temp.sort((a, b) => (b['product_name'] ?? '')
            .toString()
            .compareTo((a['product_name'] ?? '').toString()));
        break;
      case 'Latest':
        temp.sort((a, b) {
          final dateA = (a['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
          final dateB = (b['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
          return dateB.compareTo(dateA);
        });
        break;
      case 'Oldest':
        temp.sort((a, b) {
          final dateA = (a['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
          final dateB = (b['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
          return dateA.compareTo(dateB);
        });
        break;
      case 'High Rating':
        temp.sort((a, b) => ((b['rating'] ?? 0).toDouble())
            .compareTo((a['rating'] ?? 0).toDouble()));
        break;
      case 'Low Rating':
        temp.sort((a, b) => ((a['rating'] ?? 0).toDouble())
            .compareTo((b['rating'] ?? 0).toDouble()));
        break;
    }

    _filteredProducts = temp;
  }

  /// 🔹 Apply search query locally
  void _queryBasedSearch() {
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




  /// 🔹 Fetch products from Firestore
  void _fetchProducts() {
    _firestore.collection('products').snapshots().listen((snapshot) {
      _allProducts = snapshot.docs;
      // Prepare unique brands
      final brandSet = <String>{};
      final categorySet = <String>{};
      for (var doc in _allProducts) {
        final data = doc.data() as Map<String, dynamic>;
        final brand = (data['brand'] ?? '').toString().trim();
        final category = (data['category'] ?? '').toString().trim();
        if (brand.isNotEmpty) brandSet.add(brand);
        if (category.isNotEmpty) categorySet.add(category);
      }
      brands = brandSet.toList()..sort();       // Sorted list of brands
      categories = categorySet.toList()..sort(); // Sorted list of categories
      _isLoading = false;

      _applyFiltersAndSort();
      notifyListeners();
    });
  }

  /// 🔹 Force refresh
  Future<void> refresh() async {
    _isLoading = true;
    notifyListeners();

    final snapshot = await _firestore.collection('products').get();
    _allProducts = snapshot.docs;
    _isLoading = false;

    _applyFiltersAndSort();
    notifyListeners();
  }
}

