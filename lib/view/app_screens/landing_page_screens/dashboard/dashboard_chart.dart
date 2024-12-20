// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
//
// import 'order_line_chart.dart';
// import 'orders_pie_chart.dart';
//
// class DashboardCharts extends StatelessWidget {
//   final String tenantId;
//
//   DashboardCharts({required this.tenantId});
//
//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<QuerySnapshot>(
//       stream: FirebaseFirestore.instance
//           .collection('Enrolled Entities')
//           .doc(tenantId)
//           .collection('Orders')
//           .orderBy('createdAt', descending: true)
//           .snapshots(),
//       builder: (context, snapshot) {
//         if (!snapshot.hasData) {
//           return CircularProgressIndicator(); // Loading state
//         }
//
//         var orders = snapshot.data!.docs;
//         List<int> dailyOrderCounts = List.filled(7, 0); // For last 7 days
//
//         DateTime now = DateTime.now();
//
//         for (var doc in orders) {
//           DateTime orderDate = (doc['createdAt'] as Timestamp).toDate();
//           int daysAgo = now.difference(orderDate).inDays;
//           if (daysAgo < 7) {
//             dailyOrderCounts[6 - daysAgo]++; // Increment count for corresponding day
//           }
//         }
//
//         return Row(
//           children: [
//             Expanded(
//               child: Container(
//                 padding: EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(12),
//                   boxShadow: [
//                     BoxShadow(color: Colors.grey[200]!, spreadRadius: 2, blurRadius: 5),
//                   ],
//                 ),
//                 child: Column(
//                   children: [
//                     Text('Orders This Week'),
//                     SizedBox(height: 20),
//                     OrdersLineChart(orderCounts: dailyOrderCounts), // Display line chart
//                   ],
//                 ),
//               ),
//             ),
//             SizedBox(width: 16),
//             Expanded(
//               child: Container(
//                 padding: EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(12),
//                   boxShadow: [
//                     BoxShadow(color: Colors.grey[200]!, spreadRadius: 2, blurRadius: 5),
//                   ],
//                 ),
//                 child: Column(
//                   children: [
//                     Text('Success Orders'),
//                     SizedBox(height: 20),
//                     OrdersPieChart(
//                       completedOrders: orders.where((doc) => doc['status'] == 3).length,
//                       pendingOrders: orders.where((doc) => doc['status'] == 1).length,
//                       canceledOrders: orders.where((doc) => doc['status'] == 2).length,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
