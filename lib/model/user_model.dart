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
      startEndDay: data['startEndDay'] ?? false,
      viewFinance: data['viewFinance'] ?? false,
      creatingEditingProfile: data['creatingEditingProfile'] ?? false,
      addingEditingBusinessProfile: data['addingEditingBusinessProfile'] ?? false,
      addingEditingProductsDetails: data['addingEditingProductsDetails'] ?? false,
      viewingLogs: data['viewingLogs'] ?? false,
      addingEditingBankDetails: data['addingEditingBankDetails'] ?? false,
      addingEditingPrinters: data['addingEditingPrinters'] ?? false,
      voidingProducts: data['voidingProducts'] ?? false,
      voidingTableOrder: data['voidingTableOrder'] ?? false,
      addingEditingTable: data['addingEditingTable'] ?? false,
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
