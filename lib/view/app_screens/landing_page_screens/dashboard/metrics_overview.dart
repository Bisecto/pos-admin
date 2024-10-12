import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'metric_card.dart';

class MetricsOverview extends StatelessWidget {
  final String tenantId;

  MetricsOverview({required this.tenantId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Enrolled Entities')
          .doc(tenantId)
          .collection('Orders')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator(); // Loading state
        }

        // Fetch order data and calculate necessary metrics
        var orders = snapshot.data!.docs;
        int totalOrders = orders.length;
        int completedOrders = orders
            .where((doc) =>
                doc['status'] == 3) // Assuming 3 is for completed status
            .length;

        // Calculate today's orders
        DateTime now = DateTime.now();
        int todayOrders = orders.where((doc) {
          DateTime orderDate = (doc['createdAt'] as Timestamp).toDate();
          return orderDate.year == now.year &&
              orderDate.month == now.month &&
              orderDate.day == now.day;
        }).length;

        int todayCompletedOrders = orders.where((doc) {
          DateTime orderDate = (doc['createdAt'] as Timestamp).toDate();
          return orderDate.year == now.year &&
              orderDate.month == now.month &&
              orderDate.day == now.day &&
              doc['status'] == 3;
        }).length;

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            MetricCard(title: 'Total Orders', value: totalOrders.toString()),
            MetricCard(
                title: 'Completed Order', value: completedOrders.toString()),
            MetricCard(title: 'Today\'s Orders', value: todayOrders.toString()),
            MetricCard(
                title: 'Completed Today',
                value: todayCompletedOrders.toString()),
          ],
        );
      },
    );
  }
}
