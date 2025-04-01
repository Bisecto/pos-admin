import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For number formatting
import 'metric_card.dart';

class AllMetricsOverview extends StatelessWidget {
  final String tenantId;

  AllMetricsOverview({required this.tenantId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Enrolled Entities')
          .doc(tenantId)
          .collection('Orders')
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime(2024, 4, 1, 9, 0, 0)))

          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final orders = snapshot.data!.docs;

        // Process metrics
        final metrics = _calculateMetrics(orders);

        return Wrap(
          spacing: 20,
          runSpacing: 20,
          children: [
            MetricCard(title: 'Total Orders', value: metrics['totalOrders'].toString()),
            MetricCard(title: 'Completed Orders', value: metrics['completedOrders'].toString()),
            //MetricCard(title: 'Today\'s Orders', value: metrics['todayOrders'].toString()),
           // MetricCard(title: 'Completed Today', value: metrics['todayCompletedOrders'].toString()),
            MetricCard(
                title: 'Total Amount',
                value: metrics['totalAmountPaidFormatted']),
            // MetricCard(
            //     title: 'Today\'s Amount Paid (Completed)',
            //     value: metrics['todayAmountPaidFormatted']),
          ],
        );
      },
    );
  }

  Map<String, dynamic> _calculateMetrics(List<QueryDocumentSnapshot> orders) {
    int totalOrders = orders.length;
    int completedOrders = 0;
    double totalAmountPaid = 0.0;
    double todayAmountPaid = 0.0;

    final now = DateTime.now();
    int todayOrders = 0;
    int todayCompletedOrders = 0;

    for (var order in orders) {
      try {
        // Safely retrieve the data map
        final orderData = order.data() as Map<String, dynamic>?;

        // Skip if data is null or does not contain 'amountPaid'
        if (orderData == null || !orderData.containsKey('amountPaid')) {
          debugPrint("Document missing 'amountPaid' field: ${order.id}");
          continue;
        }

        final orderAmountPaid = double.tryParse(orderData['amountPaid']?.toString() ?? '0.0') ?? 0.0;

        if (orderData['status'] == 3) { // Completed orders
          totalAmountPaid += orderAmountPaid;
          completedOrders++;

          final orderDate = (orderData['createdAt'] as Timestamp).toDate();
          if (_isToday(orderDate, now)) {
            todayOrders++;
            todayAmountPaid += orderAmountPaid;
            todayCompletedOrders++;
          }
        }
      } catch (e) {
        debugPrint("Error processing order document: ${order.id}, Error: $e");
      }
    }

    final currencyFormatter = NumberFormat.currency(locale: 'en_US', symbol: '₦');

    return {
      'totalOrders': totalOrders,
      'completedOrders': completedOrders,
      'todayOrders': todayOrders,
      'todayCompletedOrders': todayCompletedOrders,
      'totalAmountPaid': totalAmountPaid,
      'totalAmountPaidFormatted': currencyFormatter.format(totalAmountPaid),
      'todayAmountPaid': todayAmountPaid,
      'todayAmountPaidFormatted': currencyFormatter.format(todayAmountPaid),
    };
  }

  bool _isToday(DateTime date, DateTime now) {
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }
}
