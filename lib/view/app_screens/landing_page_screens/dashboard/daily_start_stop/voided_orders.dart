import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:pos_admin/model/start_stop_model.dart';
import 'package:pos_admin/utills/app_utils.dart';

import '../../../../../res/app_colors.dart';
import '../../../../important_pages/export_to_excel.dart';
import '../../../../widgets/app_custom_text.dart';

class VoidedOrdersPage extends StatelessWidget {
  final String tenantId;
  final DailyStartModel dailyStartModel;

  VoidedOrdersPage({required this.tenantId, required this.dailyStartModel});

  Future<String> getUserFullName(String userId) async {
    try {
      final userSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .get();

      if (userSnapshot.exists) {
        final userData = userSnapshot.data() as Map<String, dynamic>;
        return userData['fullname'] ?? 'Unknown';
      }
      return 'Unknown';
    } catch (e) {
      print("Error fetching user full name: $e");
      return 'Unknown';
    }
  }
  Future<void> exportVoidedOrdersWithNames(
      BuildContext context, List<QueryDocumentSnapshot> voidedOrders) async {
    final List<Map<String, dynamic>> exportItems = [];

    for (final orderDoc in voidedOrders) {
      final orderData = orderDoc.data() as Map<String, dynamic>;
      final orderedById = orderData['orderedBy'] ?? '';
      final voidedById = orderData['voidedBy'] ?? '';
      final fromOrder = orderData['fromOrder'] ?? '';
      final createdAt = (orderData['createdAt'] as Timestamp?)?.toDate();

      // Get full names
      final orderedByName = await getUserFullName(orderedById);
      final voidedByName = await getUserFullName(voidedById);

      final products = List<Map<String, dynamic>>.from(orderData['products']);

      for (final product in products) {
        final total = (product['price'] ?? 0) * (product['quantity'] ?? 0);

        exportItems.add({
          'orderedBy': orderedByName,
          'productName': product['productName'],
          'createdAt': DateFormat('yyyy-MM-dd hh:mm a').format(createdAt ?? DateTime.now()),
          'quantity': product['quantity'],
          'voidedBy': voidedByName,
          'fromOrder': fromOrder,
          'total': total,
        });
      }
    }

    await ExcelExporter.exportToExcel<Map<String, dynamic>>(
      context: context,
      items: exportItems,
      fileName: 'Voided_Orders',
      toJson: (item) => item,
      customHeaders: [
        'Ordered By',
        'Product Name',
        'Time',
        'Qty',
        'Voided By',
        'From Order',
        'Total',
      ],
      includeFields: [
        'orderedBy',
        'productName',
        'createdAt',
        'quantity',
        'voidedBy',
        'fromOrder',
        'total',
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Enrolled Entities')
            .doc(tenantId.trim())
            .collection('VoidedItems')
            //.where('products', arrayContains: {'isProductVoid': true})
            .where('createdAt',
                isGreaterThanOrEqualTo: dailyStartModel.startTime)
            .where('createdAt',
                isLessThanOrEqualTo: dailyStartModel.endTime ?? DateTime.now())
            .snapshots(),
        builder: (context, snapshot) {
          print(snapshot.data);
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final voidedOrders = snapshot.data!.docs;

          if (voidedOrders.isEmpty) {
            return const Center(
              child: Text(
                "No voided orders found.",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 0.0),
                    child: GestureDetector(
                      onTap:() async {
                        await exportVoidedOrdersWithNames(context, snapshot.data!.docs);
                        // filteredProducts();
                      },
                      child: Container(
                        width: 150,
                        height: 45,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: AppColors.darkYellow),
                        child: const Padding(
                          padding: EdgeInsets.all(0.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.upload,
                                color: AppColors.white,
                              ),
                              CustomText(
                                text: "  Export",
                                size: 18,
                                color: AppColors.white,
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10,),
                  DataTable(
                    columnSpacing: 16.0,
                    dataRowColor: MaterialStateProperty.resolveWith<Color?>(
                      (Set<MaterialState> states) {
                        return Colors.black12; // Row background color
                      },
                    ),
                    headingRowColor: MaterialStateProperty.resolveWith<Color?>(
                      (Set<MaterialState> states) {
                        return Colors.black45; // Header background color
                      },
                    ),
                    columns: const [
                      DataColumn(
                        label: Text(
                          'Ordered By',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Product Name',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Time',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Qty',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),

                      DataColumn(
                        label: Text(
                          'Voided By',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),DataColumn(
                        label: Text(
                          'From Order',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Total',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ],
                    rows: voidedOrders.expand((orderDoc) {
                      final orderData = orderDoc.data() as Map<String, dynamic>;
                      final products =
                          List<Map<String, dynamic>>.from(orderData['products']);
                      return products

                          .map((voidedProduct) {
                        return DataRow(cells: [
                          DataCell(FutureBuilder<String>(
                            future: getUserFullName(orderData['orderedBy'] ?? ''),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Text('Loading...',
                                    style: TextStyle(color: Colors.grey));
                              }
                              if (snapshot.hasError) {
                                return const Text('Error',
                                    style: TextStyle(color: Colors.red));
                              }
                              return Text(
                                snapshot.data ?? 'Unknown',
                                style: const TextStyle(color: Colors.white),
                              );
                            },
                          )),
                          // DataCell(Text(orderDoc.id.substring(0, 5),
                          //     style: const TextStyle(color: Colors.white))),
                          DataCell(Text(voidedProduct['productName'],
                              style: const TextStyle(color: Colors.white))),
                          DataCell(Text(
                        AppUtils.formateTime(
                        dateTime: (orderData['createdAt'] as Timestamp?)?.toDate() ??
                        DateTime.now(),
                        ),
                              style: const TextStyle(color: Colors.white))),
                          DataCell(Text((voidedProduct['quantity']).toString(),
                              style: const TextStyle(color: Colors.white))),

                          DataCell(FutureBuilder<String>(
                            future:
                                getUserFullName(orderData['voidedBy'] ?? ''),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Text('Loading...',
                                    style: TextStyle(color: Colors.grey));
                              }
                              if (snapshot.hasError) {
                                return const Text('Error',
                                    style: TextStyle(color: Colors.red));
                              }
                              return Text(
                                snapshot.data ?? 'Unknown',
                                style: const TextStyle(color: Colors.white),
                              );
                            },
                          )),
                          DataCell(Text((orderData['fromOrder']).toString(),
                              style: const TextStyle(color: Colors.white))),

                          DataCell(Text(
                              (voidedProduct['price'] * voidedProduct['quantity'])
                                  .toString(),
                              style: const TextStyle(color: Colors.white))),
                        ]);
                      });
                    }).toList(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
