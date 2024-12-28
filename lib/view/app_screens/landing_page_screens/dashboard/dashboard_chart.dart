import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../model/start_stop_model.dart';
import '../../../../res/app_colors.dart';
import '../../../widgets/app_custom_text.dart';

class OrdersByUsersPage extends StatefulWidget {
  final String tenantId;
  final DailyStartModel dailyStartModel; // Start date

  OrdersByUsersPage({
    required this.tenantId, required this.dailyStartModel,

  });

  @override
  _OrdersByUsersPageState createState() => _OrdersByUsersPageState();
}

class _OrdersByUsersPageState extends State<OrdersByUsersPage> {
  late Future<Map<String, double>> ordersSummaryFuture;

  Future<Map<String, double>> getOrdersSummaryByUsers(
      String tenantId, DateTime startTime, DateTime endTime) async {
    try {
      // Step 1: Fetch all users for the given tenantId
      QuerySnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('tenantId', isEqualTo: tenantId.trim())
          .get();

      Map<String, double> ordersSummary = {};

      // Step 2: Iterate through each user to fetch their orders in the date range
      for (var userDoc in userSnapshot.docs) {
        var userData = userDoc.data() as Map<String, dynamic>;
        String userId = userDoc.id;

        // Fetch orders for this user within the date range
        QuerySnapshot orderSnapshot = await FirebaseFirestore.instance
            .collection('Enrolled Entities')
            .doc(tenantId)
            .collection('Orders')
            .where('updatedBy', isEqualTo: userId)
            .where('createdAt', isGreaterThanOrEqualTo: startTime)
            .where('createdAt', isLessThanOrEqualTo: endTime)
            .get();

        // Calculate total amount for this user
        double totalAmount = 0;
        for (var orderDoc in orderSnapshot.docs) {
          var orderData = orderDoc.data() as Map<String, dynamic>;
          if (orderData['amountPaid'] != null) {
            final parsedAmount =
                double.tryParse(orderData['amountPaid'].toString()) ?? 0.0;
            totalAmount += parsedAmount;
          }
        }

        if (totalAmount > 0) {
          ordersSummary[userData['fullname'] ?? 'Unknown User'] = totalAmount;
        }
      }

      return ordersSummary;
    } catch (e) {
      print("Error fetching orders: $e");
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use the provided startTime and endTime
    final startTime = widget.dailyStartModel.startTime ?? DateTime.now();
    final endTime = widget.dailyStartModel.endTime ?? DateTime.now();

    ordersSummaryFuture =
        getOrdersSummaryByUsers(widget.tenantId, startTime, endTime);

    return Column(
      children: [
        FutureBuilder<Map<String, double>>(
          future: ordersSummaryFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(15.0, 50, 15, 15),
                  child: CustomText(
                      text:
                      'No user booked and completed an order in the selected date range.',
                      color: AppColors.white),
                ),
              );
            }

            final ordersSummary = snapshot.data!;

            return Container(
              height: ordersSummary.length * 100,
              child: ListView.builder(
                itemCount: ordersSummary.length,
                itemBuilder: (context, index) {
                  String user = ordersSummary.keys.elementAt(index);
                  double totalAmount = ordersSummary.values.elementAt(index);

                  return Card(
                    margin: const EdgeInsets.all(8.0),
                    color: Colors.black12,
                    child: ListTile(
                      leading: const Icon(Icons.person, color: Colors.blue),
                      title: CustomText(
                        text: user.toUpperCase(),
                        size: 16,
                        color: AppColors.white,
                      ),
                      subtitle: CustomText(
                        text:
                        'Total Order Amount: NGN ${totalAmount.toStringAsFixed(2)}',
                        color: AppColors.white,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
