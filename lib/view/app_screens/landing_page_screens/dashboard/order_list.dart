import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../model/order_model.dart';
import '../../../../res/app_colors.dart';
import '../../../../utills/app_utils.dart';
import '../../../widgets/app_custom_text.dart';
import 'date_filter.dart';

class OrderList extends StatelessWidget {
  final String tenantId;

  OrderList({required this.tenantId});

  @override
  Widget build(BuildContext context) {
    final selectedDate = Provider.of<DateFilterProvider>(context).selectedDate;
    final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Enrolled Entities')
          .doc(tenantId)
          .collection('Orders')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final orders = snapshot.data!.docs.where((doc) {
          final order =
              OrderModel.fromFirestore(doc.data() as Map<String, dynamic>);
          final orderDate = DateFormat('yyyy-MM-dd').format(order.createdAt);
          return orderDate == formattedDate;
        });

        final itemQuantities = _calculateItemQuantities(orders);

        if (itemQuantities.isEmpty) {
          return _buildNoOrdersView(formattedDate);
        }

        return _buildOrderList(itemQuantities);
      },
    );
  }

  Map<String, int> _calculateItemQuantities(
      Iterable<QueryDocumentSnapshot> orders) {
    final itemQuantities = <String, int>{};

    for (var doc in orders) {
      final order =
          OrderModel.fromFirestore(doc.data() as Map<String, dynamic>);
      for (var product in order.products) {
        itemQuantities[product.productName] =
            (itemQuantities[product.productName] ?? 0) + product.quantity;
      }
    }

    return itemQuantities;
  }

  Widget _buildNoOrdersView(String formattedDate) {
    return Align(
      alignment: Alignment.topLeft,
      child: Container(
        width: 300,
        padding: const EdgeInsets.all(16),

        child: CustomText(
          text:
              "No orders found for ${AppUtils.formateSimpleDate(dateTime: formattedDate)}",color: AppColors.white,
        ),
      ),
    );
  }

  Widget _buildOrderList(Map<String, int> itemQuantities) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      children: itemQuantities.entries.map((entry) {
        return ListTile(
          leading: Icon(Icons.shopping_cart, color: Colors.grey[600]),
          title: CustomText(
            text: entry.key,
            color: AppColors.white,
          ),
          subtitle: CustomText(
            text: 'Total Ordered: ${entry.value}',
            color: AppColors.white,
          ),
        );
      }).toList(),
    );
  }
}
