import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String userId;
  String email;
  String fullname;
  String imageUrl;
  String phone;
  String role;
  String tenantId;
  bool accountStatus;
  Timestamp createdAt;
  Timestamp updatedAt;

  // Activity roles as boolean fields
  bool startEndDay;
  bool viewFinance;
  bool creatingEditingProfile;
  bool addingEditingBusinessProfile;
  bool addingEditingProductsDetails;
  bool viewingLogs;
  bool addingEditingBankDetails;
  bool addingEditingPrinters;
  bool voidingProducts;
  bool voidingTableOrder;
  bool addingEditingTable;

  UserModel({
    required this.userId,
    required this.email,
    required this.fullname,
    required this.imageUrl,
    required this.phone,
    required this.role,
    required this.tenantId,
    required this.createdAt,
    required this.updatedAt,
    required this.accountStatus,
    this.startEndDay = false,
    this.viewFinance = false,
    this.creatingEditingProfile = false,
    this.addingEditingBusinessProfile = false,
    this.addingEditingProductsDetails = false,
    this.viewingLogs = false,
    this.addingEditingBankDetails = false,
    this.addingEditingPrinters = false,
    this.voidingProducts = false,
    this.voidingTableOrder = false,
    this.addingEditingTable = false,
  });

  // Factory method to create a UserModel from Firestore DocumentSnapshot
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      userId: data['userId'] ?? '',
      email: data['email'] ?? '',
      fullname: data['fullname'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      phone: data['phone'] ?? '',
      role: data['role'] ?? '',
      tenantId: data['tenantId'] ?? '',
      createdAt: data['createdAt'],
      updatedAt: data['updatedAt'],
      accountStatus: data['accountStatus'] ?? false,
      startEndDay: data['startEndDay'] ?? data['role'].toString().toLowerCase()=='admin'?true: false,
      viewFinance: data['viewFinance'] ?? data['role'].toString().toLowerCase()=='admin'?true:false,
      creatingEditingProfile: data['creatingEditingProfile'] ?? data['role'].toString().toLowerCase()=='admin'?true: false,
      addingEditingBusinessProfile: data['addingEditingBusinessProfile'] ?? data['role'].toString().toLowerCase()=='admin'?true:false,
      addingEditingProductsDetails: data['addingEditingProductsDetails'] ?? data['role'].toString().toLowerCase()=='admin'?true: false,
      viewingLogs: data['viewingLogs'] ?? data['role'].toString().toLowerCase()=='admin'?true:false,
      addingEditingBankDetails: data['addingEditingBankDetails'] ??data['role'].toString().toLowerCase()=='admin'?true: false,
      addingEditingPrinters: data['addingEditingPrinters'] ?? data['role'].toString().toLowerCase()=='admin'?true: false,
      voidingProducts: data['voidingProducts'] ??data['role'].toString().toLowerCase()=='admin'?true: false,
      voidingTableOrder: data['voidingTableOrder'] ??data['role'].toString().toLowerCase()=='admin'?true: false,
      addingEditingTable: data['addingEditingTable'] ??data['role'].toString().toLowerCase()=='admin'?true: false,
    );
  }

  // Method to convert UserModel object to a map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'email': email,
      'fullname': fullname,
      'imageUrl': imageUrl,
      'phone': phone,
      'role': role,
      'tenantId': tenantId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'accountStatus': accountStatus,
      'startEndDay': startEndDay,
      'viewFinance': viewFinance,
      'creatingEditingProfile': creatingEditingProfile,
      'addingEditingBusinessProfile': addingEditingBusinessProfile,
      'addingEditingProductsDetails': addingEditingProductsDetails,
      'viewingLogs': viewingLogs,
      'addingEditingBankDetails': addingEditingBankDetails,
      'addingEditingPrinters': addingEditingPrinters,
      'voidingProducts': voidingProducts,
      'voidingTableOrder': voidingTableOrder,
      'addingEditingTable': addingEditingTable,
    };
  }
}
