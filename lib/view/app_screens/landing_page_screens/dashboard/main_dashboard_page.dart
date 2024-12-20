import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pos_admin/model/user_model.dart';
import 'package:pos_admin/view/app_screens/landing_page_screens/dashboard/recent_orders.dart';

import '../../../../res/app_colors.dart';
import 'dashboard_chart.dart';
import 'metrics_overview.dart'; // For charts

class Dashboard extends StatelessWidget {
  final String tenantId;
  final UserModel userModel;

  Dashboard({required this.tenantId, required this.userModel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor, // Dashboard background color
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // Metrics Overview
              MetricsOverview(tenantId: tenantId),
              const SizedBox(height: 20),

              // Dashboard Charts
              // SizedBox(
              //   height: 300, // Define a fixed height for the charts
              //   child: DashboardCharts(tenantId: tenantId),
              // ),
              // const SizedBox(height: 20),

              // Recent Orders
              SizedBox(
                height: 400, // Define a fixed height for recent orders
                child: RecentOrders(
                  tenantId: tenantId.trim(),
                  userModel: userModel,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
