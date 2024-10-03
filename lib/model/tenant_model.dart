import 'package:cloud_firestore/cloud_firestore.dart';

import 'address_model.dart';
import 'business_hours_model.dart';

class Business {
  String businessName;
  String businessPhoneNumber;
  String businessType;
  String email;
  String logoUrl;
  Timestamp createdAt;
  Timestamp updatedAt;
  Address address;
  Map<String, BusinessHours> businessHours;

  Business({
    required this.businessName,
    required this.businessPhoneNumber,
    required this.businessType,
    required this.email,
    required this.logoUrl,
    required this.createdAt,
    required this.updatedAt,
    required this.address,
    required this.businessHours,
  });

  // Factory method to create a Business from Firestore DocumentSnapshot
  factory Business.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Business(
      businessName: data['businessName'],
      businessPhoneNumber: data['businessPhoneNumber'],
      businessType: data['businessType'],
      email: data['email'],
      logoUrl: data['logoUrl'] ?? '',
      createdAt: data['createdAt'],
      updatedAt: data['updatedAt'],
      address: Address.fromFirestore(data['address']),
      businessHours: (data['businessHours'] as Map<String, dynamic>).map(
            (day, hours) => MapEntry(
          day,
          BusinessHours.fromFirestore(hours),
        ),
      ),
    );
  }

  // Method to convert Business object to a map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'businessName': businessName,
      'businessPhoneNumber': businessPhoneNumber,
      'businessType': businessType,
      'email': email,
      'logoUrl': logoUrl,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'address': address.toFirestore(),
      'businessHours': businessHours.map(
            (day, hours) => MapEntry(day, hours.toFirestore()),
      ),
    };
  }
}
