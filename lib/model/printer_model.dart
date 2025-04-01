import 'package:cloud_firestore/cloud_firestore.dart';

class PrinterModel {
  String printerId;
  String printerName;
  String ip;
  String port;
  bool isPrinterUsb;
  String type;
  String createdBy;
  String updatedBy;
  Timestamp createdAt;
  Timestamp updatedAt;
  PrinterModel({
    required this.printerId,
    required this.printerName,
    required this.ip,
    required this.port,
    required this.isPrinterUsb,
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
      isPrinterUsb: data['isPrinterUsb']??false,
      port: data['port'] as String,
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
      'isPrinterUsb': isPrinterUsb,
      'port': port,
      'type': type,
      'createdBy': createdBy,
      'updatedBy': updatedBy,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
