import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../model/order_model.dart';
import '../../../../model/start_stop_model.dart';
import '../../../../res/app_colors.dart';
import '../../../../utills/app_utils.dart';
import '../../../important_pages/export_to_excel.dart';
import '../../../widgets/app_custom_text.dart';

class OrderList extends StatefulWidget {
  final String tenantId;
  final DailyStartModel dailyStartModel;

  OrderList({required this.tenantId, required this.dailyStartModel});

  @override
  State<OrderList> createState() => _OrderListState();
}

class _OrderListState extends State<OrderList> {
  Future<void> exportOrderSummaryToExcel({
    required BuildContext context,
    required String tenantId,
    required DailyStartModel dailyStartModel,
  }) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('Enrolled Entities')
          .doc(tenantId)
          .collection('Orders')
          .where('createdAt',
              isGreaterThanOrEqualTo:
                  dailyStartModel.startTime ?? DateTime(2000))
          .where('createdAt',
              isLessThanOrEqualTo: dailyStartModel.endTime ?? DateTime.now())
          .orderBy('createdAt', descending: true)
          .get();

      final orders = querySnapshot.docs.map((doc) {
        return OrderModel.fromFirestore(doc.data() as Map<String, dynamic>);
      }).toList();

      var filteredOrders = orders.where((order) {
        return order.products.any((product) => product.isProductVoid == false);
      }).toList();

      filteredOrders = filteredOrders
          .map((order) {
            order.products
                .removeWhere((product) => product.isProductVoid == true);
            return order;
          })
          .where((order) => order.products.isNotEmpty)
          .toList();

      final summary = <Map<String, dynamic>>[];

      final itemMap = <String, Map<String, dynamic>>{};
      for (final order in filteredOrders) {
        for (final product in order.products) {
          final key = product.productName;
          final quantity = product.quantity;
          final price = product.price;

          if (itemMap.containsKey(key)) {
            itemMap[key]!['quantity'] += quantity;
            itemMap[key]!['totalPrice'] += quantity * price;
          } else {
            itemMap[key] = {
              'productName': key,
              'quantity': quantity,
              'totalPrice': quantity * price,
            };
          }
        }
      }

      summary.addAll(itemMap.values);
      final totalQuantity = summary.fold<int>(
        0,
            (sum, item) => sum + (item['quantity'] as int),
      );

      final totalPrice = summary.fold<double>(
        0.0,
            (sum, item) => sum + (item['totalPrice'] as num).toDouble(),
      );

// Add the final summary row
      summary.add({
        'productName': 'Total',
        'quantity': totalQuantity,
        'totalPrice': totalPrice,
      });

      if (summary.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No non-voided items found to export.')),
        );
        return;
      }

      await ExcelExporter.exportToExcel<Map<String, dynamic>>(
        context: context,
        items: summary,
        fileName: 'Daily_Orders_Summary',
        toJson: (item) => item,
        customHeaders: ['Item', 'Quantity', 'Total Price'],
        includeFields: ['productName', 'quantity', 'totalPrice'],
      );
    } catch (e) {
      print("Error exporting summary: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Enrolled Entities')
          .doc(widget.tenantId)
          .collection('Orders')
          .where('createdAt',
              isGreaterThanOrEqualTo:
                  widget.dailyStartModel.startTime ?? DateTime(2000))
          .where('createdAt',
              isLessThanOrEqualTo:
                  widget.dailyStartModel.endTime ?? DateTime.now())
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(
            child: Text(
              'An error occurred while loading orders.',
              style: TextStyle(color: Colors.red),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildNoOrdersView(
              widget.dailyStartModel.startTime, widget.dailyStartModel.endTime);
        }

        try {
          // Convert Firestore documents to OrderModel
          final orders = snapshot.data!.docs
              .map((doc) =>
                  OrderModel.fromFirestore(doc.data() as Map<String, dynamic>))
              .toList();

          // Filter orders to only include those that have at least one product with isProductVoid: false
          var filteredOrders = orders.where((order) {
            return order.products.any((product) {
              print(product.productName);
              print(product.isProductVoid);
              return product.isProductVoid == false;
            });
          }).toList();
          filteredOrders = filteredOrders
              .map((order) {
                order.products
                    .removeWhere((product) => product.isProductVoid == true);
                return order;
              })
              .where((order) => order.products.isNotEmpty)
              .toList();
          // print(filteredOrders.length);
          if (filteredOrders.isEmpty) {
            return _buildNoOrdersView(widget.dailyStartModel.startTime,
                widget.dailyStartModel.endTime);
          }

          final itemQuantities = _calculateItemQuantities(filteredOrders);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 0.0),
                child: GestureDetector(
                  onTap: () async {
                    exportOrderSummaryToExcel(
                      context: context,
                      tenantId: widget.tenantId.trim(),
                      dailyStartModel: widget.dailyStartModel,
                    );
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
              _buildOrderList(itemQuantities),
            ],
          );
        } catch (e) {
          return Center(
            child: Text(
              'Error processing data: $e',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }
      },
    );
  }

  Map<String, Map<String, dynamic>> _calculateItemQuantities(
      List<OrderModel> orders) {
    final itemSummary = <String, Map<String, dynamic>>{};

    for (var order in orders) {
      for (var product in order.products) {
        final productName = product.productName;
        final productQuantity = product.quantity;
        final productPrice = product.price;

        if (itemSummary.containsKey(productName)) {
          itemSummary[productName]!['quantity'] += productQuantity;
          itemSummary[productName]!['totalPrice'] +=
              productQuantity * productPrice;
        } else {
          itemSummary[productName] = {
            'quantity': productQuantity,
            'totalPrice': productQuantity * productPrice,
          };
        }
      }
    }

    return itemSummary;
  }

  Widget _buildNoOrdersView(DateTime? startDate, DateTime? endDate) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.black,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade800,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: CustomText(
          text: "No orders found.",
          color: AppColors.white,
          size: 16,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildOrderList(Map<String, Map<String, dynamic>> itemSummary) {
    return ListView(
      shrinkWrap: true,
      // Allows it to wrap content
      physics: NeverScrollableScrollPhysics(),
      // Prevents scrolling inside another scrollable widget
      children: [
        DataTable(
          headingRowColor: MaterialStateProperty.all(Colors.grey.shade900),
          dataRowColor: MaterialStateProperty.all(Colors.grey.shade800),
          columns: const [
            DataColumn(
              label: Text(
                'Item',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Quantity',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Total Price',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
          rows: itemSummary.entries.map((entry) {
            final itemName = entry.key;
            final quantity = entry.value['quantity'];
            final totalPrice = entry.value['totalPrice'];

            return DataRow(
              cells: [
                DataCell(Text(itemName,
                    style: const TextStyle(color: Colors.white))),
                DataCell(Text('$quantity',
                    style: const TextStyle(color: Colors.white))),
                DataCell(Text('NGN ${totalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.white))),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}
