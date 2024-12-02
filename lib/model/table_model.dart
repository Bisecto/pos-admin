import 'package:cloud_firestore/cloud_firestore.dart';

import 'activity_model.dart';


class TableModel {
  final ActivityModel activity;
  final String tableId;
  final String tableName;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  TableModel({
    required this.activity,
    required this.tableId,
    required this.tableName,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory method to create a TableModel instance from Firestore data
  factory TableModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return TableModel(
      activity: ActivityModel.fromMap(data['activities'] as Map<String, dynamic>),
      tableId: data['tableId'] as String,
      tableName: data['tableName'] as String,
      createdAt: data['createdAt'] as Timestamp,
      updatedAt: data['updatedAt'] as Timestamp,
    );
  }

  // Method to convert TableModel instance to Firestore-compatible data
  Map<String, dynamic> toFirestore() {
    return {
      'activities': activity.toMap(),
      'tableId': tableId,
      'tableName': tableName,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
