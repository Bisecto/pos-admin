import 'package:flutter/material.dart';
import 'package:pos_admin/res/app_colors.dart';
import 'package:provider/provider.dart';
import '../../../widgets/app_custom_text.dart';
import 'all_metrics.dart';
import 'dashboard_chart.dart';
import 'date_filter.dart';
import 'date_picker.dart';
import 'metrics_overview.dart';
import 'recent_orders.dart';

class Dashboard extends StatelessWidget {
  final String tenantId;

  Dashboard({required this.tenantId});

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

                    AllMetricsOverview(tenantId: tenantId),
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

                    MetricsOverview(tenantId: tenantId),
                    OrdersByUsersPage(tenantId: tenantId),
                    RecentOrders(
                      tenantId: tenantId,
                    ),
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
