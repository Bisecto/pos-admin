import 'package:cloud_firestore/cloud_firestore.dart';

class Brand {
  String? brandId;
  String? brandName;
  Timestamp? createdAt;
  String? createdBy;
  String updatedBy;
  Timestamp updatedAt;

  Brand({
    required this.brandId,
    required this.brandName,
    required this.createdAt,
    required this.createdBy,
    required this.updatedBy,
    required this.updatedAt,
  });

  // Factory method to create a Brand from Firestore DocumentSnapshot
  factory Brand.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Brand(
      brandId: data['brandId'],
      brandName: data['brandName'],
      createdAt: data['createdAt'],
      createdBy: data['createdBy'],
      updatedBy: data['updatedBy'],
      updatedAt: data['updatedAt'],
    );
  }

  // Method to convert brand object to a map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'brandId': brandId,
      'brandName': brandName,
      'createdAt': createdAt,
      'createdBy': createdBy,
      'updatedBy': updatedBy,
      'updatedAt': updatedAt,
    };
  }
}
