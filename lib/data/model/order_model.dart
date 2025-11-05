import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String id;
  final Map<String, dynamic> address;
  final String payment;
  final String deliveryDate;
  final Timestamp createdAt;
  final List<Map<String, dynamic>> items;
  final Map<String, dynamic> bill;

  OrderModel({
    required this.id,
    required this.address,
    required this.payment,
    required this.deliveryDate,
    required this.createdAt,
    required this.items,
    required this.bill,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'address': address,
      'payment': payment,
      'delivery_date': deliveryDate,
      'created_at': createdAt,
      'items': items,
      'bill': bill,
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return OrderModel(
      id: id??map['id'] ?? '',
      address: Map<String, dynamic>.from(map['address'] ?? {}),
      payment: map['payment'] ?? '',
      deliveryDate: map['delivery_date'] ?? '',
      createdAt: map['created_at'] is Timestamp
          ? map['created_at'] as Timestamp
          : Timestamp.fromDate(DateTime.tryParse(map['created_at'] ?? '') ?? DateTime.now()),      items: List<Map<String, dynamic>>.from(map['items'] ?? []),
      bill: Map<String, dynamic>.from(map['bill'] ?? {}),
    );
  }
}
