import 'package:cloud_firestore/cloud_firestore.dart';

import 'address_model.dart';
import 'business_hours_model.dart' as businesTime;

class TenantModel {
  String businessName;
  String businessPhoneNumber;
  String businessType;
  String email;
  String logoUrl;
  double vat;
  Timestamp createdAt;
  Timestamp updatedAt;
  Address address;
  final String subscriptionPlan;
  final DateTime? subscriptionStart;
  final DateTime? subscriptionEnd;
  final bool isSubscriptionActive;
  Map<String, businesTime.BusinessHours> businessHours;

  TenantModel( {
    required this.businessName,
    required this.businessPhoneNumber,
    required this.businessType,
    required this.email,
    required this.logoUrl,
    required this.vat,
    required this.createdAt,
    required this.updatedAt,
    required this.address,
    required this.subscriptionPlan,
    required this.subscriptionStart,
    required this.subscriptionEnd,
    required this.isSubscriptionActive,
    required this.businessHours,
  });

  // Factory method to create a TenantModel from Firestore DocumentSnapshot
  factory TenantModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return TenantModel(
      businessName: data['businessName'],
      businessPhoneNumber: data['businessPhoneNumber'],
      businessType: data['businessType'],
      email: data['email'],
      logoUrl: data['logoUrl'] ?? '',
      vat: double.parse(data['vat'].toString()) ,
      createdAt: data['createdAt'],
      updatedAt: data['updateAt'],
      address: Address.fromFirestore(data['address']),
      subscriptionPlan: data['subscriptionPlan'] ?? 'starter',
      subscriptionStart: (data['subscriptionStart'] as Timestamp?)?.toDate(),
      subscriptionEnd: (data['subscriptionEnd'] as Timestamp?)?.toDate(),
      isSubscriptionActive: data['isSubscriptionActive'] ?? false,
      businessHours: (data['businessHours'] as Map<String, dynamic>).map(
        (day, hours) => MapEntry(
          day,
          businesTime.BusinessHours.fromFirestore(hours),
        ),
      ),
    );
  }

  // Method to convert TenantModel object to a map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'businessName': businessName,
      'businessPhoneNumber': businessPhoneNumber,
      'businessType': businessType,
      'email': email,
      'logoUrl': logoUrl,
      'vat': vat,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'address': address.toFirestore(),
      'subscriptionPlan': subscriptionPlan,
      'subscriptionStart': subscriptionStart,
      'subscriptionEnd': subscriptionEnd,
      'isSubscriptionActive': isSubscriptionActive,
      'businessHours': businessHours.map(
        (day, hours) => MapEntry(day, hours.toFirestore()),
      ),
    };
  }
}
