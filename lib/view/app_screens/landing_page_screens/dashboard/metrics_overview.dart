import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../model/start_stop_model.dart';
import '../../../../utills/enums/order_status_enums.dart';
import 'metric_card.dart';

class MetricsOverview extends StatelessWidget {
  final String tenantId;
  final DailyStartModel dailyStartModel;

  MetricsOverview({
    required this.tenantId,
    required this.dailyStartModel,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Enrolled Entities')
          .doc(tenantId)
          .collection('Orders')
          .where('createdAt', isGreaterThanOrEqualTo: dailyStartModel.startTime)
          .where('createdAt',
              isLessThanOrEqualTo: dailyStartModel.endTime ?? DateTime.now())
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final allOrders = snapshot.data!.docs;

        // Total orders count
        final totalOrders = allOrders.length;

        // Completed orders count
        final completedOrders = allOrders.where((order) {
          print(order['orderId']);
          print(order['status'] == OrderStatus.completed.index.toString());
          print(OrderStatus.completed.index.runtimeType);
          print(order['status']);
          return order['status'] ==
              int.parse(OrderStatus.completed.index
                  .toString()); // Enum index for completed
        }).toList();

        final completedOrdersCount = completedOrders.length;

        // Total amount paid for completed orders
        final totalAmountPaid = completedOrders.fold<double>(
          0.0,
          (sum, order) => sum + (double.parse(order['amountPaid']) ?? 0.0),
        );

        final totalAmountPaidFormatted =
            '\$${totalAmountPaid.toStringAsFixed(2)}';

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            MetricCard(
              title: 'Total Orders',
              value: totalOrders.toString(),
            ),
            MetricCard(
              title: 'Completed Orders',
              value: completedOrdersCount.toString(),
            ),
            MetricCard(
              title: 'Total Amount Paid',
              value: totalAmountPaidFormatted,
            ),
          ],
        );
      },
    );
  }
}
