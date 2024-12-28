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

  OrderList({required this.tenantId,  required this.dailyStartModel});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Enrolled Entities')
          .doc(tenantId)
          .collection('Orders')
          .where('createdAt', isGreaterThanOrEqualTo: dailyStartModel.startTime)
          .where('createdAt', isLessThanOrEqualTo: dailyStartModel.endTime ?? DateTime.now())
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final orders = snapshot.data!.docs.map((doc) {
          return OrderModel.fromFirestore(doc.data() as Map<String, dynamic>);
        }).toList();

        final itemQuantities = _calculateItemQuantities(orders);

        if (itemQuantities.isEmpty) {
          return _buildNoOrdersView(dailyStartModel.startTime, dailyStartModel.endTime);
        }

        return _buildOrderList(itemQuantities);
      },
    );
  }

  Map<String, int> _calculateItemQuantities(List<OrderModel> orders) {
    final itemQuantities = <String, int>{};

    for (var order in orders) {
      for (var product in order.products) {
        itemQuantities[product.productName] =
            (itemQuantities[product.productName] ?? 0) + product.quantity;
      }
    }

    return itemQuantities;
  }

  Widget _buildNoOrdersView(DateTime? startDate, DateTime? endDate) {
    final dateRange = startDate != null
        ? "from ${AppUtils.formateSimpleDate(dateTime: dailyStartModel.startTime.toString())} to ${AppUtils.formateSimpleDate(dateTime: dailyStartModel.endTime.toString())}"
        : "recent dates";

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
          text: "No orders found $dateRange.",
          color: AppColors.white,
          size: 16,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildOrderList(Map<String, int> itemQuantities) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: itemQuantities.length,
      itemBuilder: (context, index) {
        final entry = itemQuantities.entries.elementAt(index);
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          color: Colors.grey.shade900,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: Icon(Icons.shopping_cart, color: Colors.blue.shade300),
            title: CustomText(
              text: entry.key,
              color: AppColors.white,
              size: 16,
              weight: FontWeight.bold,
            ),
            subtitle: CustomText(
              text: 'Total Ordered: ${entry.value}',
              color: AppColors.white,
              size: 14,
            ),
          ),
        );
      },
    );
  }
}
