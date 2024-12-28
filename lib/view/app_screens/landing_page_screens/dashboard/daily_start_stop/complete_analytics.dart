import 'package:flutter/material.dart';
import 'package:pos_admin/model/start_stop_model.dart';
import 'package:pos_admin/view/app_screens/landing_page_screens/dashboard/dashboard_chart.dart';
import 'package:provider/provider.dart';

import '../../../../../model/user_model.dart';
import '../metrics_overview.dart';
import '../recent_orders.dart';

class CompleteAnalytics extends StatelessWidget {
  final UserModel startedUser;
   UserModel? endeduser;
  final DailyStartModel dailyStartModel;

  //final

   CompleteAnalytics({
    super.key,
    required this.startedUser,
     this.endeduser, required this.dailyStartModel,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          MetricsOverview(tenantId: startedUser.tenantId.trim(), dailyStartModel: dailyStartModel,),
          OrdersByUsersPage(tenantId: startedUser.tenantId.trim(),dailyStartModel: dailyStartModel,),
          RecentOrders(
            tenantId: startedUser.tenantId.trim(), dailyStartModel: dailyStartModel,
          ),
        ],
      ),
    );
  }
}
