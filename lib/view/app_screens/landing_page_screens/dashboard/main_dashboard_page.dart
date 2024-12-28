import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pos_admin/model/user_model.dart';
import 'package:pos_admin/res/app_colors.dart';
import 'package:provider/provider.dart';
import '../../../../model/activity_model.dart';
import '../../../../model/log_model.dart';
import '../../../../model/table_model.dart';
import '../../../../repository/log_actions.dart';
import '../../../../res/app_enums.dart';
import '../../../important_pages/dialog_box.dart';
import '../../../widgets/app_custom_text.dart';
import '../../../widgets/form_button.dart';
import 'all_metrics.dart';
import 'dashboard_chart.dart';
import 'date_filter.dart';
import 'date_picker.dart';
import 'daily_start_stop/day_start_stop.dart';
import 'metrics_overview.dart';
import 'recent_orders.dart';

class Dashboard extends StatefulWidget {
  final String tenantId;
  final UserModel userModel;

  Dashboard({required this.tenantId, required this.userModel});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  Future<List<LogModel>> fetchDayStartStop(String tenantId) async {
    try {
      final cashierStartStop = FirebaseFirestore.instance
          .collection('Enrolled Entities')
          .doc(tenantId.trim())
          .collection('cashierStartStop');

      final querySnapshot = await cashierStartStop.get();

      return querySnapshot.docs.map((doc) {
        return LogModel.fromFirestore(doc);
      }).toList();
    } catch (e) {
      print("Failed to fetch StartStop: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DateFilterProvider(),
      child: Scaffold(
        backgroundColor: AppColors.black,
        appBar: AppBar(
          backgroundColor: AppColors.black,
          title: const CustomText(
            text: 'Overall Analytics',
            color: AppColors.white,
            weight: FontWeight.bold,
            size: 22,
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [

                    AllMetricsOverview(tenantId: widget.tenantId),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const CustomText(
                            text: 'Daily Analytics',
                            color: AppColors.white,
                            weight: FontWeight.bold,
                            size: 18,
                          ),
                          DatePickerWidget(),
                        ],
                      ),
                    ),
                    DayStartStopPage(tenantId: widget.tenantId.trim(),)

                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
