import 'package:cloud_firestore/cloud_firestore.dart';

class PrinterModel {
   String printerId; // Firestore document ID
   String printerName; // Printer name
   String ip; // Printer IP address
   int port; // Printer port
   String type; // Printer type (e.g., thermal, inkjet)
   String createdBy; // User ID of creator
   String updatedBy; // User ID of last updater
   Timestamp createdAt; // Timestamp for creation
   Timestamp updatedAt; // Timestamp for last update

  PrinterModel({
    required this.printerId,
    required this.printerName,
    required this.ip,
    required this.port,
    required this.type,
    required this.createdBy,
    required this.updatedBy,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory constructor to create a PrinterModel from Firestore document
  factory PrinterModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return PrinterModel(
      printerId: data['printerId'],
      printerName: data['printerName'] as String,
      ip: data['ip'] as String,
      port: data['port'] as int,
      type: data['type'] as String,
      createdBy: data['createdBy'] as String,
      updatedBy: data['updatedBy'] as String,
      createdAt: data['createdAt'] as Timestamp,
      updatedAt: data['updatedAt'] as Timestamp,
    );
  }

  // Method to convert PrinterModel to a Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'printerName': printerName,
      'ip': ip,
      'printerId':printerId,
      'port': port,
      'type': type,
      'createdBy': createdBy,
      'updatedBy': updatedBy,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
