import 'package:cloud_firestore/cloud_firestore.dart';

class Bank {
  String bankId;
  String bankName;
  String accountNumber;
  String accountName;
  Timestamp createdAt;
  String createdBy;
  String updatedBy;
  Timestamp updatedAt;

  Bank({
    required this.bankId,
    required this.bankName,
    required this.accountNumber,
    required this.accountName,
    required this.createdAt,
    required this.createdBy,
    required this.updatedBy,
    required this.updatedAt,
  });

  // Factory method to create a Bank from Firestore DocumentSnapshot
  factory Bank.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Bank(
      bankId: data['bankId'],
      bankName: data['bankName'],
      createdAt: data['createdAt'],
      createdBy: data['createdBy'],
      updatedBy: data['updatedBy'],
      updatedAt: data['updatedAt'],
      accountNumber: data['accountNumber'],
      accountName: data['accountName'],
    );
  }

  // Method to convert bank object to a map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'bankId': bankId,
      'bankName': bankName,
      'accountNumber': accountNumber,
      'accountName': accountName,
      'createdAt': createdAt,
      'createdBy': createdBy,
      'updatedBy': updatedBy,
      'updatedAt': updatedAt,
    };
  }
}
