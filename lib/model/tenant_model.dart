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
  Timestamp queryStartDate;
  Timestamp updatedAt;
  Address address;
  Map<String, businesTime.BusinessHours> businessHours;

  TenantModel({
    required this.businessName,
    required this.businessPhoneNumber,
    required this.businessType,
    required this.email,
    required this.logoUrl,
    required this.vat,
    required this.createdAt,
    required this.queryStartDate,
    required this.updatedAt,
    required this.address,
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
      queryStartDate: data['queryStartDate'],
      updatedAt: data['updateAt'],
      address: Address.fromFirestore(data['address']),
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
      'queryStartDate': queryStartDate,
      'updatedAt': updatedAt,
      'address': address.toFirestore(),
      'businessHours': businessHours.map(
        (day, hours) => MapEntry(day, hours.toFirestore()),
      ),
    };
  }
}
