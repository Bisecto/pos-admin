import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pos_admin/res/app_colors.dart';
import 'package:pos_admin/utills/app_utils.dart';
import 'package:pos_admin/view/widgets/form_button.dart';

import '../../../../model/order_model.dart';
import '../../../../model/user_model.dart';
import '../../../widgets/app_custom_text.dart';

class RecentOrders extends StatefulWidget {
  final String tenantId;
  final UserModel userModel;

  RecentOrders({required this.tenantId, required this.userModel});

  @override
  _RecentOrdersState createState() => _RecentOrdersState();
}

class _RecentOrdersState extends State<RecentOrders> {
  DateTime selectedDate = DateTime.now();

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String formattedSelectedDate =
        DateFormat('yyyy-MM-dd').format(selectedDate);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //: ${AppUtils.formateSimpleDate(dateTime: formattedSelectedDate.toString())}
        FormButton(
          onPressed: () => _selectDate(context),
          text:
              "Select Date: ${AppUtils.formateSimpleDate(dateTime: formattedSelectedDate.toString())}",
          width: 250,
          borderRadius: 20,
        ),
        // ElevatedButton(
        //   onPressed: () => _selectDate(context),
        //   child: Text("Select Date: $formattedSelectedDate"),
        // ),
        const SizedBox(
          height: 15,
        ),
        Expanded(
          // Ensure scrollability within the widget
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('Enrolled Entities')
                .doc(widget.tenantId)
                .collection('Orders')
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              var orders = snapshot.data!.docs;

              // Filter orders by the selected day
              var filteredOrders = orders.where((doc) {
                var order = OrderModel.fromFirestore(
                    doc.data() as Map<String, dynamic>);
                var orderDate =
                    DateFormat('yyyy-MM-dd').format(order.createdAt);
                return orderDate == formattedSelectedDate;
              });

              // Group items and calculate total quantities for the selected day
              Map<String, int> itemQuantities = {};
              for (var doc in filteredOrders) {
                var order = OrderModel.fromFirestore(
                    doc.data() as Map<String, dynamic>);
                for (var product in order.products) {
                  itemQuantities[product.productName] =
                      (itemQuantities[product.productName] ?? 0) +
                          product.quantity;
                }
              }

              if (itemQuantities.isEmpty) {
                return Container(
                  width: 250,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey[700]!,
                          spreadRadius: 2,
                          blurRadius: 5),
                    ],
                  ),
                  child: Center(
                    child: CustomText(
                      text:
                          "No orders found for ${AppUtils.formateSimpleDate(dateTime: formattedSelectedDate.toString())}",
                      //style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                );
              }

              return Container(
                width: 250,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey[700]!,
                        spreadRadius: 2,
                        blurRadius: 5),
                  ],
                ),
                child: ListView(
                  children: itemQuantities.entries.map((entry) {
                    return ListTile(
                      leading:
                          Icon(Icons.shopping_cart, color: Colors.grey[600]),
                      title: CustomText(
                        text: entry.key,
                        color: AppColors.white,
                      ), // Item name
                      subtitle: CustomText(
                          text: 'Total Ordered: ${entry.value}',
                          color: AppColors.white), // Total quantity
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
