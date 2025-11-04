import 'package:cloud_firestore/cloud_firestore.dart';


import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String productName;
  final double retailPrice;
  final double discountedPrice;
  final String description;
  final List<String> imageUrls; // 🔹 Multiple images
  final String category;
  final String subCategory; // 🔹 Added sub-category
  final int stock;
  final String brand;
  final double rating;
  final int reviewsCount;
  final bool isFreeShipping;
  final String returnPolicy;
  final Map<String, dynamic> specifications; // 🔹 Key-value specs
  final int totalBought;
  final DateTime? createdAt;

  Product({
    required this.id,
    required this.productName,
    required this.retailPrice,
    required this.discountedPrice,
    required this.description,
    required this.imageUrls,
    required this.category,
    required this.subCategory,
    required this.stock,
    required this.brand,
    required this.rating,
    required this.reviewsCount,
    required this.isFreeShipping,
    required this.returnPolicy,
    required this.specifications,
    required this.totalBought,
    this.createdAt,
  });

  /// ✅ From Firestore document
  factory Product.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      productName: data['product_name'] ?? '',
      retailPrice: (data['retail_price'] ?? 0).toDouble(),
      discountedPrice: (data['discounted_price'] ?? 0).toDouble(),
      description: data['description'] ?? '',
      imageUrls: List<String>.from(data['images'] ?? []),
      category: data['category'] ?? '',
      subCategory: data['subCategory'] ?? '',
      stock: (data['stock'] ?? 0).toInt(),
      brand: data['brand'] ?? '',
      rating: (data['rating'] ?? 0).toDouble(),
      reviewsCount: (data['review_count'] ?? 0).toInt(),
      isFreeShipping: data['shipping_type']=='Free' ,
      returnPolicy: data['return_policy'] ?? 'No return policy available.',
      specifications:
      Map<String, dynamic>.from(data['specifications'] ?? {}),
      totalBought: (data['total_buy'] ?? 0).toInt(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  /// ✅ To Firestore JSON
  Map<String, dynamic> toJson() {
    return {
      'product_name': productName,
      'retail_price': retailPrice,
      'discounted_price': discountedPrice,
      'description': description,
      'images': imageUrls,
      'category': category,
      'subCategory': subCategory,
      'stock': stock,
      'brand': brand,
      'rating': rating,
      'reviews_count': reviewsCount,
      'is_free_shipping': isFreeShipping,
      'return_policy': returnPolicy,
      'specifications': specifications,
      'total_buy': totalBought,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }
}

