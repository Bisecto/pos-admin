import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../../model/order_model.dart';

class RecentOrders extends StatelessWidget {
  final String tenantId;

  RecentOrders({required this.tenantId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Enrolled Entities')
          .doc(tenantId)
          .collection('Orders')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }

        var orders = snapshot.data!.docs;

        return Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                  color: Colors.grey[200]!, spreadRadius: 2, blurRadius: 5),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: orders.map((doc) {
              var order =
                  OrderModel.fromFirestore(doc.data() as Map<String, dynamic>);
              return OrderListItem(order: order);
            }).toList(),
          ),
        );
      },
    );
  }
}

class OrderListItem extends StatelessWidget {
  final OrderModel order;

  OrderListItem({required this.order});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.shopping_bag, size: 40, color: Colors.grey[600]),
      title: Text(order.products[0].productName),
      // Display the first product name
      subtitle: Text('${order.products.length} items'),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          //Text('${order.createdAt.toLocal()}'),
          Chip(
              label: Text(
                  order.status.toString().split('.').last)), // Display status
        ],
      ),
    );
  }
}
