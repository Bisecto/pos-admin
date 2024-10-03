import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  String categoryId;
  String categoryName;
  Timestamp createdAt;
  String createdBy;
  String productId;
  String productImageUrl;
  String productName;
  Timestamp updatedAt;
  String updatedBy;

  Product({
    required this.categoryId,
    required this.categoryName,
    required this.createdAt,
    required this.createdBy,
    required this.productId,
    required this.productImageUrl,
    required this.productName,
    required this.updatedAt,
    required this.updatedBy,
  });

  // Factory method to create a Product from Firestore DocumentSnapshot
  factory Product.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Product(
      categoryId: data['categoryId'],
      categoryName: data['categoryName'],
      createdAt: data['createdAt'],
      createdBy: data['createdBy'],
      productId: data['productId'],
      productImageUrl: data['productImageUrl'],
      productName: data['productName'],
      updatedAt: data['updatedAt'],
      updatedBy: data['updatedBy'],
    );
  }

  // Method to convert Product object to a map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'categoryId': categoryId,
      'categoryName': categoryName,
      'createdAt': createdAt,
      'createdBy': createdBy,
      'productId': productId,
      'productImageUrl': productImageUrl,
      'productName': productName,
      'updatedAt': updatedAt,
      'updatedBy': updatedBy,
    };
  }
}
