import 'package:cloud_firestore/cloud_firestore.dart';

class Category {
  String categoryId;
  String categoryName;
  Timestamp createdAt;
  String createdBy;
  String updatedBy;
  Timestamp updatedAt;

  Category({
    required this.categoryId,
    required this.categoryName,
    required this.createdAt,
    required this.createdBy,
    required this.updatedBy,
    required this.updatedAt,
  });

  // Factory method to create a Category from Firestore DocumentSnapshot
  factory Category.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Category(
      categoryId: data['categoryId'],
      categoryName: data['categoryName'],
      createdAt: data['createdAt'],
      createdBy: data['createdBy'],
      updatedBy: data['updatedBy'],
      updatedAt: data['updatedAt'],
    );
  }

  // Method to convert Category object to a map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'categoryId': categoryId,
      'categoryName': categoryName,
      'createdAt': createdAt,
      'createdBy': createdBy,
      'updatedBy': updatedBy,
      'updatedAt': updatedAt,
    };
  }
}
