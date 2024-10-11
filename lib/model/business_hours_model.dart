import 'package:cloud_firestore/cloud_firestore.dart';

class BusinessHours {
  Timestamp? opening;
  Timestamp? closing;

  BusinessHours({
    this.opening,
    this.closing,
  });

  // Factory method to create BusinessHours from Firestore DocumentSnapshot
  factory BusinessHours.fromFirestore(Map<String, dynamic> data) {
    return BusinessHours(
      opening: data['opening'] != null ? data['opening'] as Timestamp : null,
      closing: data['closing'] != null ? data['closing'] as Timestamp : null,
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
