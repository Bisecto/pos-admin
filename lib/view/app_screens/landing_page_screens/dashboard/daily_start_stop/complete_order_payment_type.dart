import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../../../model/start_stop_model.dart';

class CompletedOrdersByPayment extends StatelessWidget {
  final String tenantId;
  final DailyStartModel dailyStartModel;

  CompletedOrdersByPayment(
      {required this.tenantId, required this.dailyStartModel});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('Enrolled Entities')
          .doc(tenantId)
          .collection('Orders')
          .where('status', isEqualTo: 3)
          .where('createdAt', isGreaterThanOrEqualTo: dailyStartModel.startTime)
          .where('createdAt',
              isLessThanOrEqualTo: dailyStartModel.endTime ?? DateTime.now())
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final orders = snapshot.data!.docs;

        // Group orders by payment method and calculate total amounts
        final Map<String, double> paymentTotals = {
          'Cash': 0.0,
          'Card': 0.0,
          'Transfer': 0.0,
        };

        for (var doc in orders) {
          var orderData = doc.data() as Map<String, dynamic>;
          String paymentMethod = orderData['paymentMethod'] ?? 'Unknown';
          double amountPaid =
              double.tryParse(orderData['amountPaid'].toString()) ?? 0.0;

          if (paymentTotals.containsKey(paymentMethod)) {
            paymentTotals[paymentMethod] =
                (paymentTotals[paymentMethod] ?? 0) + amountPaid;
          } else {
            paymentTotals['Unknown'] =
                (paymentTotals['Unknown'] ?? 0) + amountPaid;
          }
        }

        return _buildPaymentTable(paymentTotals);
      },
    );
  }

  Widget _buildPaymentTable(Map<String, double> paymentTotals) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: DataTable(
        columnSpacing: 24.0,
        headingTextStyle:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        dataTextStyle: const TextStyle(color: Colors.white),
        columns: const [
          DataColumn(label: Text('Payment Method')),
          DataColumn(label: Text('Total Amount (\$)')),
        ],
        rows: paymentTotals.entries.map((entry) {
          return DataRow(
            cells: [
              DataCell(Text(entry.key)),
              DataCell(Text(entry.value.toStringAsFixed(2))),
            ],
          );
        }).toList(),
      ),
    );
  }
}
