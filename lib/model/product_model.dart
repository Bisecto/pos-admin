import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  String? categoryId;
  Timestamp createdAt;
  String createdBy;
  String? brandId;
  String productId;
  String productImageUrl;
  String productName;
  String productType;
  String sku;
  double price;
  int qty;
  double discount;
  Timestamp updatedAt;
  String updatedBy;

  Product({
    required this.categoryId,
    required this.createdAt,
    required this.createdBy,
    required this.brandId,
    required this.price,
    required this.discount,
    required this.productId,
    required this.productImageUrl,
    required this.productName,
    required this.productType,
    required this.sku,
    required this.qty,
    required this.updatedAt,
    required this.updatedBy,
  });

  // Convert Firestore document to Product object
  factory Product.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Product(
      categoryId: data['categoryId'],
      createdAt: data['createdAt'],
      createdBy: data['createdBy'],
      brandId: data['brandId'],
      price: double.parse(data['price'].toString()),
      discount: double.parse(data['discount'].toString()) ,
      productId: data['productId'],
      productImageUrl: data['productImageUrl'],
      productName: data['productName'],
      productType: data['productType'],
      sku: data['sku'],
      qty: data['qty']??0,
      updatedAt: data['updatedAt'],
      updatedBy: data['updatedBy'],
    );
  }

  // Convert Product object to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'categoryId': categoryId,
      'createdAt': createdAt,
      'createdBy': createdBy,
      'brandId': brandId,
      'productId': productId,
      'productImageUrl': productImageUrl,
      'productName': productName,
      'productType': productType,
      'price': price,
      'discount': discount,
      'sku': sku,
      'qty': qty,
      'updatedAt': updatedAt,
      'updatedBy': updatedBy,
    };
  }
  Map<String, dynamic> toJson() {
    return {
      'categoryId': categoryId,
      'createdAt': createdAt,
      'createdBy': createdBy,
      'brandId': brandId,
      'productId': productId,
      'productImageUrl': productImageUrl,
      'productName': productName,
      'productType': productType,
      'price': price,
      'discount': discount,
      'sku': sku,
      'qty': qty,
      'updatedAt': updatedAt,
      'updatedBy': updatedBy,
    };
  }

}
