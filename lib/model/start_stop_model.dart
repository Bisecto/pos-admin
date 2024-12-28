import 'package:cloud_firestore/cloud_firestore.dart';

class DailyStartModel {
  final String? id; // Firestore document ID
  final String userId;
  final String userRole;
  final String tenantId;
  final DateTime? startTime;
  final DateTime? endTime;
  final String status; // active, ended
  final Map<String, dynamic>? endedBy;

  DailyStartModel({
    this.id,
    required this.userId,
    required this.userRole,
    required this.tenantId,
    this.startTime,
    this.endTime,
    required this.status,
    this.endedBy,
  });

  // Factory method to create an instance from Firestore data
  factory DailyStartModel.fromFirestore(
      Map<String, dynamic> data, String documentId) {
    return DailyStartModel(
      id: documentId,
      userId: data['userId'] ?? '',
      userRole: data['userRole'] ?? '',
      tenantId: data['tenantId'] ?? '',
      startTime: data['startTime'] != null
          ? (data['startTime'] as Timestamp).toDate()
          : null,
      endTime: data['endTime'] != null
          ? (data['endTime'] as Timestamp).toDate()
          : null,
      status: data['status'] ?? '',
      endedBy: data['endedBy'] as Map<String, dynamic>?,
    );
  }

  // Convert an instance to Firestore data
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userRole': userRole,
      'tenantId': tenantId,
      'startTime': startTime != null ? Timestamp.fromDate(startTime!) : null,
      'endTime': endTime != null ? Timestamp.fromDate(endTime!) : null,
      'status': status,
      'endedBy': endedBy,
    };
  }
}
