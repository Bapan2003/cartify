class CartModel {
  final String id;
  final String title;
  final String image;
  final double discountedPrice;
  final int quantity;
  final int stock;

  final String shippingType;
  final String returnPolicy;
  final int totalBought;

  CartModel({
    required this.id,
    required this.title,
    required this.image,
    required this.discountedPrice,
    this.quantity = 1,
    required this.stock,
    this.shippingType = 'Free Shipping',
    this.returnPolicy = '7 Days Return Policy',
    this.totalBought = 0,
  });

  /// ✅ Convert to Map for Firestore
  Map<String, dynamic> toMap() => {
    'id': id,
    'product_name': title,
    'imageUrl': image,
    'discounted_price': discountedPrice,
    'quantity': quantity,
    'stock': stock,
    'shipping_type': shippingType,
    'return_policy': returnPolicy,
    'total_bought': totalBought,
  };

  /// ✅ Create from Firestore document or Map
  factory CartModel.fromMap(Map<String, dynamic> map, String id,{int? qty}) {
    final imageUrl = (map['images'] != null &&
        map['images'] is List &&
        (map['images'] as List).isNotEmpty)
        ? (map['images'] as List).first
        : (map['imageUrl'] ?? '');

    return CartModel(
      id: id,
      title: map['product_name'] ?? '',
      image: imageUrl,
      discountedPrice:
      (map['discounted_price'] ?? map['discountedPrice'] ?? 0).toDouble(),
      quantity:qty?? (map['quantity'] ?? 1) as int,
      stock: (map['stock'] ?? 0) as int,
      shippingType: map['shipping_type'] ?? map['shippingType'] ?? 'Free Shipping',
      returnPolicy:
      map['return_policy'] ?? map['return_policy'] ?? '7 Days Return Policy',
      totalBought: (map['total_buy'] ?? map['total_bought'] ?? 0) as int,
    );
  }
}
