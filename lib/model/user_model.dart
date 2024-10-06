import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String userId;
  String email;
  String fullname;
  String imageUrl;
  String phone;
  String role;
  String tenantId;
  bool accountStatus;
  Timestamp createdAt;
  Timestamp updatedAt;

  UserModel({
    required this.userId,
    required this.email,
    required this.fullname,
    required this.imageUrl,
    required this.phone,
    required this.role,
    required this.tenantId,
    required this.createdAt,
    required this.updatedAt,
    required this.accountStatus,
  });

  // Factory method to create a UserModel from Firestore DocumentSnapshot
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      userId: data['userId'],
      email: data['email'],
      fullname: data['fullname'],
      imageUrl: data['imageUrl'],
      phone: data['phone'],
      role: data['role'],
      tenantId: data['tenantId'],
      createdAt: data['createdAt'],
      updatedAt: data['updatedAt'],
      accountStatus: data['accountStatus'],
    );
  }

  // Method to convert UserModel object to a map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'email': email,
      'fullname': fullname,
      'imageUrl': imageUrl,
      'phone': phone,
      'role': role,
      'tenantId': tenantId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'accountStatus': accountStatus,
    };
  }
}
