import 'package:cloud_firestore/cloud_firestore.dart';

import '../utills/enums/order_status_enums.dart';

class OrderModel {
  final List<OrderProduct> products;
  final String createdBy;
  String orderCode;
  String orderTo;
  String tableNo;
  final String updatedBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final OrderStatus status;

  OrderModel({
    required this.products,
    required this.createdBy,
    required this.orderCode,
    required this.tableNo,
    required this.orderTo,
    required this.updatedBy,
    required this.createdAt,
    required this.updatedAt,
    required this.status,
  });

  // Factory method to create OrderModel from Firestore document
  factory OrderModel.fromFirestore(Map<String, dynamic> json) {
    return OrderModel(
      products: (json['products'] as List)
          .map((item) => OrderProduct.fromJson(item))
          .toList(),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
      createdBy: json['createdBy'],
      updatedBy: json['updatedBy'],
      status: OrderStatus.values[json['status']],
      orderCode: 'orderCode',
      tableNo: 'tableNo',
      orderTo: 'orderTo',
    );
  }

  // Convert OrderModel to JSON for saving to Firestore
  Map<String, dynamic> toJson() {
    return {
      'products': products.map((product) => product.toJson()).toList(),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'updatedBy': updatedBy,
      'createdBy': createdBy,
      'status': status.index,
      'orderCode': orderCode,
      'orderTo': orderTo,
      'tableNo': tableNo,
    };
  }
}

class OrderProduct {
  final String productName;
  final String productId;
  final int quantity;
  final double price;
  final double discount;
  final String productImage;
  final String brandId;
  final String categoryId;
  final String sku;

  OrderProduct({
    required this.productName,
    required this.productId,
    required this.quantity,
    required this.price,
    required this.discount,
    required this.productImage,
    required this.brandId,
    required this.categoryId,
    required this.sku,
  });

  // Factory method to create OrderProduct from JSON
  factory OrderProduct.fromJson(Map<String, dynamic> json) {
    return OrderProduct(
      productName: json['productName'],
      productId: json['productId'],
      quantity: json['quantity'],
      price: json['price'],
      discount: json['discount'],
      productImage: json['productImage'],
      brandId: json['brandId'],
      categoryId: json['categoryId'],
      sku: json['sku'],
    );
  }

  // Convert OrderProduct to JSON
  Map<String, dynamic> toJson() {
    return {
      'productName': productName,
      'productId': productId,
      'quantity': quantity,
      'price': price,
      'discount': discount,
      'productImage': productImage,
      'brandId': brandId,
      'categoryId': categoryId,
      'sku': sku,
    };
  }
}

// Enum for order status
