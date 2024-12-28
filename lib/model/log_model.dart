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
          : FieldValue.serverTimestamp(),
    };
  }

  // Create a model instance from Firestore map data
  factory LogModel.fromMap(Map<String, dynamic> map) {
    return LogModel(
      actionType: map['actionType'] as String? ?? '',
      actionDescription: map['actionDescription'] as String? ?? '',
      performedBy: map['performedBy'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      timestamp: (map['timestamp'] as Timestamp?)?.toDate(),
    );
  }

  // Create a model instance from Firestore document snapshot
  factory LogModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LogModel.fromMap(data);
  }

  // Create a model instance from Firestore QueryDocumentSnapshot
  factory LogModel.fromFirestore(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    return LogModel(
      actionType: doc.data()['actionType'] ?? '',
      actionDescription: doc.data()['actionDescription'] ?? '',
      performedBy: doc.data()['performedBy'] ?? '',
      userId: doc.data()['userId'] ?? '',
      timestamp: (doc.data()['timestamp'] as Timestamp?)?.toDate(),
    );
  }
}
