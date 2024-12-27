import 'package:cloud_firestore/cloud_firestore.dart';

class LogModel {
  final String actionType;
  final String actionDescription;
  final String performedBy;
  final String userId;
  final DateTime? timestamp;

  LogModel({
    required this.actionType,
    required this.actionDescription,
    required this.performedBy,
    required this.userId,
    this.timestamp,
  });

  // Convert model to Firestore-compatible map
  Map<String, dynamic> toMap() {
    return {
      'actionType': actionType,
      'actionDescription': actionDescription,
      'performedBy': performedBy,
      'userId': userId,
      'timestamp': timestamp != null
          ? Timestamp.fromDate(timestamp!)
          : FieldValue.serverTimestamp(), // Corrected with parentheses
    };
  }

  // Create a model instance from Firestore data
  factory LogModel.fromMap(Map<String, dynamic> map) {
    return LogModel(
      actionType: map['actionType'] ?? '',
      actionDescription: map['actionDescription'] ?? '',
      performedBy: map['performedBy'] ?? '',
      userId: map['userId'] ?? '',
      timestamp: (map['timestamp'] as Timestamp?)?.toDate(),
    );
  }
}
