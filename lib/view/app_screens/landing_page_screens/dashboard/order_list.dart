import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../model/order_model.dart';
import '../../../../model/start_stop_model.dart';
import '../../../../res/app_colors.dart';
import '../../../../utills/app_utils.dart';
import '../../../widgets/app_custom_text.dart';

class OrderList extends StatelessWidget {
  final String tenantId;
  final DailyStartModel dailyStartModel;

  OrderList({required this.tenantId, required this.dailyStartModel});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Enrolled Entities')
          .doc(tenantId)
          .collection('Orders')
          .where('createdAt',
              isGreaterThanOrEqualTo:
                  dailyStartModel.startTime ?? DateTime(2000))
          .where('createdAt',
              isLessThanOrEqualTo: dailyStartModel.endTime ?? DateTime.now())
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
              dailyStartModel.startTime, dailyStartModel.endTime);
        }

        try {
          final orders = snapshot.data!.docs.map((doc) {
            return OrderModel.fromFirestore(doc.data() as Map<String, dynamic>);
          }).toList();

          final itemQuantities = _calculateItemQuantities(orders);

          if (itemQuantities.isEmpty) {
            return _buildNoOrdersView(
                dailyStartModel.startTime, dailyStartModel.endTime);
          }

          return _buildOrderList(itemQuantities);
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
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
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
              DataCell(
                  Text(itemName, style: const TextStyle(color: Colors.white))),
              DataCell(Text('$quantity',
                  style: const TextStyle(color: Colors.white))),
              DataCell(Text('NGN ${totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.white))),
            ],
          );
        }).toList(),
      ),
    );
  }
}
