import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'date_filter.dart';
import 'metric_card.dart';

class MetricsOverview extends StatelessWidget {
  final String tenantId;

  MetricsOverview({required this.tenantId});

  @override
  Widget build(BuildContext context) {
    final selectedDate = Provider.of<DateFilterProvider>(context).selectedDate;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Enrolled Entities')
          .doc(tenantId)
          .collection('Orders')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final allOrders = snapshot.data!.docs;

        // Calculate today's orders
        final todayOrders = allOrders.where((order) {
          DateTime orderDate = (order['createdAt'] as Timestamp).toDate();
          return orderDate.year == selectedDate.year &&
              orderDate.month == selectedDate.month &&
              orderDate.day == selectedDate.day;
        }).toList();

        // Calculate completed orders
        final completedOrders = allOrders.where((order) {
          return order['status'] == 'completed';
        }).toList();

        // Calculate today's completed orders
        final todayCompletedOrders = todayOrders.where((order) {
          return order['status'] == 'completed';
        }).toList();

        // Calculate total amount paid for completed orders
        final totalAmountPaid = completedOrders.fold<double>(
          0.0,
              (sum, order) => sum + (order['amountPaid'] ?? 0.0),
        );

        // Calculate today's amount paid for completed orders
        final todayAmountPaid = todayCompletedOrders.fold<double>(
          0.0,
              (sum, order) => sum + (order['amountPaid'] ?? 0.0),
        );

        // Format amount paid for display

        final todayAmountPaidFormatted =
            '\$${todayAmountPaid.toStringAsFixed(2)}';

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [

            MetricCard(
              title: 'Orders',
              value: todayOrders.length.toString(),
            ),
            MetricCard(
              title: 'Completed Orders',
              value: todayCompletedOrders.length.toString(),
            ),

            MetricCard(
              title: 'Amount Paid',
              value: todayAmountPaidFormatted,
            ),
          ],
        );
      },
    );
  }
}
