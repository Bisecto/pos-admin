import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pos_admin/model/start_stop_model.dart';
import 'package:pos_admin/utills/app_utils.dart';

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

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Enrolled Entities')
            .doc(tenantId.trim())
            .collection('Orders')
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
              child: DataTable(
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
                      'User',
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
                      .where((product) => product['isProductVoid'] == true)
                      .map((voidedProduct) {
                    return DataRow(cells: [
                      DataCell(FutureBuilder<String>(
                        future: getUserFullName(orderData['createdBy'] ?? ''),
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
                    dateTime: (voidedProduct['updatedAt'] as Timestamp?)?.toDate() ??
                    DateTime.now(),
                    ),
                          style: const TextStyle(color: Colors.white))),
                      DataCell(Text((voidedProduct['quantity']).toString(),
                          style: const TextStyle(color: Colors.white))),

                      DataCell(FutureBuilder<String>(
                        future:
                            getUserFullName(voidedProduct['voidedBy'] ?? ''),
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
                      DataCell(Text(
                          (voidedProduct['price'] * voidedProduct['quantity'])
                              .toString(),
                          style: const TextStyle(color: Colors.white))),
                    ]);
                  });
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }
}
