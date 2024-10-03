import 'package:cloud_firestore/cloud_firestore.dart';

class BusinessHours {
  Timestamp opening;
  Timestamp closing;

  BusinessHours({
    required this.opening,
    required this.closing,
  });

  // Factory method to create BusinessHours from Firestore DocumentSnapshot
  factory BusinessHours.fromFirestore(Map<String, dynamic> data) {
    return BusinessHours(
      opening: data['opening'],
      closing: data['closing'],
    );
  }

  // Method to convert BusinessHours object to a map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'opening': opening,
      'closing': closing,
    };
  }
}
