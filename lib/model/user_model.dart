import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String userId;
  String email;
  String fullname;
  String imageUrl;
  String phone;
  String role;
  String tenantId;
  Timestamp createdAt;
  Timestamp updatedAt;

  User({
    required this.userId,
    required this.email,
    required this.fullname,
    required this.imageUrl,
    required this.phone,
    required this.role,
    required this.tenantId,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory method to create a User from Firestore DocumentSnapshot
  factory User.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return User(
      userId: data['userId'],
      email: data['email'],
      fullname: data['fullname'],
      imageUrl: data['imageUrl'],
      phone: data['phone'],
      role: data['role'],
      tenantId: data['tenantId'],
      createdAt: data['createdAt'],
      updatedAt: data['updatedAt'],
    );
  }

  // Method to convert User object to a map for Firestore
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
    };
  }
}
