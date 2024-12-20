import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import for number formatting
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

        // Fetch order data
        var orders = snapshot.data!.docs;

        // Metrics initialization
        int totalOrders = orders.length;
        int completedOrders = 0;
        double totalAmountPaid = 0;
        double todayAmountPaid = 0;

        // Date setup for today's orders
        DateTime now = DateTime.now();
        int todayOrders = 0;
        int todayCompletedOrders = 0;

        // Format numbers as money
        final currencyFormatter = NumberFormat.currency(locale: 'en_US', symbol: '₦');

        // Iterate over orders and calculate totals for completed orders only
        for (var order in orders) {
          if (order['status'] == 3) { // Only completed orders
            var products = order['products'] as List;
            double orderTotal = products.fold(0, (sum, item) {
              var product = item as Map<String, dynamic>;
              double price = double.parse(product['price'].toString());
              double discount = double.parse(product['discount'].toString());
              int quantity = product['quantity'];
              return sum + ((price - discount) * quantity);
            });

            // Add to total amount for completed orders
            totalAmountPaid += orderTotal;
            completedOrders++;

            // Check if the order is from today
            DateTime orderDate = (order['createdAt'] as Timestamp).toDate();
            if (orderDate.year == now.year &&
                orderDate.month == now.month &&
                orderDate.day == now.day) {
              todayOrders++;
              todayAmountPaid += orderTotal;
              todayCompletedOrders++;
            }
          }
        }

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            MetricCard(title: 'Total Orders', value: totalOrders.toString()),
            MetricCard(
                title: 'Completed Orders', value: completedOrders.toString()),
            MetricCard(
                title: 'Today\'s Orders', value: todayOrders.toString()),
            MetricCard(
                title: 'Completed Today', value: todayCompletedOrders.toString()),
            MetricCard(
                title: 'Total Amount Paid (Completed)',
                value: currencyFormatter.format(totalAmountPaid)),
            MetricCard(
                title: 'Today\'s Amount Paid (Completed)',
                value: currencyFormatter.format(todayAmountPaid)),
            // Add more cards as needed for additional metrics
          ],
        );
      },
    );
  }
}
