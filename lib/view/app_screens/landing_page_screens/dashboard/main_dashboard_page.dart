import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pos_admin/view/app_screens/landing_page_screens/dashboard/recent_orders.dart';

import '../../../../res/app_colors.dart';
import 'dashboard_chart.dart';
import 'metrics_overview.dart'; // For charts

class Dashboard extends StatelessWidget {
  final String tenantId;

  Dashboard({required this.tenantId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white, // Dashboard background color
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 20),

              MetricsOverview(tenantId: tenantId),
              // Fetch and display metrics
              SizedBox(height: 20),
              DashboardCharts(tenantId: tenantId),
              // Fetch and display charts
              SizedBox(height: 20),
              RecentOrders(tenantId: tenantId),
              // Fetch and display recent orders
            ],
          ),
        ),
      ),
    );
  }
}
