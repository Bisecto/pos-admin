import 'package:cloud_firestore/cloud_firestore.dart';

import 'order_model.dart';

class VoidModel {
  final String orderedBy;
  final String voidedBy;
  final String fromOrder;
  final List<OrderProduct> products;
  final DateTime? createdAt;

  VoidModel({
    required this.orderedBy,
    required this.voidedBy,
    required this.fromOrder,
    required this.products,
    this.createdAt,
  });

  // Convert VoidModel to Firestore-compatible map
  Map<String, dynamic> toMap() {
    return {
      'orderedBy': orderedBy,
      'voidedBy': voidedBy,
      'fromOrder': fromOrder,
      'products': products.map((product) => product.toJson()).toList(),
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  // Create VoidModel instance from Firestore map data
  factory VoidModel.fromMap(Map<String, dynamic> map) {
    return VoidModel(
      orderedBy: map['orderedBy'] as String? ?? '',
      voidedBy: map['voidedBy'] as String? ?? '',
      fromOrder: map['fromOrder'] as String? ?? '',
      products: (map['products'] as List<dynamic>)
          .map((product) => OrderProduct.fromJson(product as Map<String, dynamic>))
          .toList(),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  // Create VoidModel instance from Firestore document snapshot
  factory VoidModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return VoidModel.fromMap(data);
  }

  // Create VoidModel instance from Firestore QueryDocumentSnapshot
  factory VoidModel.fromFirestore(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    return VoidModel(
      orderedBy: doc.data()['orderedBy'] ?? '',
      voidedBy: doc.data()['voidedBy'] ?? '',
      fromOrder: doc.data()['fromOrder'] ?? '',
      products: (doc.data()['products'] as List<dynamic>)
          .map((product) => OrderProduct.fromJson(product as Map<String, dynamic>))
          .toList(),
      createdAt: (doc.data()['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
