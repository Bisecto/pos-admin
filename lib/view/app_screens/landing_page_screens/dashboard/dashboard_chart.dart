import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../../../../res/app_colors.dart';
import '../../../widgets/app_custom_text.dart';
import 'date_filter.dart';

class OrdersByUsersPage extends StatefulWidget {
  final String tenantId;

  OrdersByUsersPage({required this.tenantId});

  @override
  _OrdersByUsersPageState createState() => _OrdersByUsersPageState();
}

class _OrdersByUsersPageState extends State<OrdersByUsersPage> {
  //DateTime? selectedDate;
  late Future<Map<String, double>> ordersSummaryFuture;

  // @override
  // void initState() {
  //   super.initState();
  //   // Initialize with today's date by default
  //   //selectedDate = DateTime.now();
  // }

  Future<Map<String, double>> getOrdersSummaryByUsers(
      String tenantId, DateTime date) async {
    try {
      // Step 1: Fetch all users for the given tenantId
      QuerySnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('tenantId', isEqualTo: tenantId.trim())
          .get();

      Map<String, double> ordersSummary = {};

      // Step 2: Iterate through each user to fetch their orders for the selected date
      for (var userDoc in userSnapshot.docs) {
        var userData = userDoc.data() as Map<String, dynamic>;
        String userId = userDoc.id;

        // Define start and end of the selected date
        DateTime startOfDay = DateTime(date.year, date.month, date.day);
        DateTime endOfDay = startOfDay
            .add(const Duration(days: 1))
            .subtract(const Duration(seconds: 1));

        // Fetch orders for this user on the selected date
        QuerySnapshot orderSnapshot = await FirebaseFirestore.instance
            .collection('Enrolled Entities')
            .doc(tenantId)
            .collection('Orders')
            .where('updatedBy', isEqualTo: userId)
            .where('createdAt', isGreaterThanOrEqualTo: startOfDay)
            .where('createdAt', isLessThanOrEqualTo: endOfDay)
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
          // totalAmount += (orderData['amountPaid'] ?? 0).toDouble();
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
    final selectedDate = Provider.of<DateFilterProvider>(context).selectedDate;
    ordersSummaryFuture =
        getOrdersSummaryByUsers(widget.tenantId, selectedDate);

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
                          'No User booked and completed an order on the selected date.',
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
                            'Total Order Amount: \$${totalAmount.toStringAsFixed(2)}',
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
