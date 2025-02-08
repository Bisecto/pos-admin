import 'package:flutter/material.dart';
import 'package:pos_admin/model/start_stop_model.dart';
import 'package:pos_admin/view/app_screens/landing_page_screens/dashboard/daily_start_stop/voided_orders.dart';
import 'package:pos_admin/view/app_screens/landing_page_screens/dashboard/dashboard_chart.dart';
import 'package:pos_admin/view/widgets/app_custom_text.dart';
import 'package:provider/provider.dart';

import '../../../../../model/user_model.dart';
import '../../../../../res/app_colors.dart';
import '../../logs/log_page.dart';
import '../metrics_overview.dart';
import '../recent_orders.dart';
import 'complete_order_payment_type.dart';

class CompleteAnalytics extends StatelessWidget {
  final UserModel startedUser;
  final UserModel userModel;

  UserModel? endeduser;
  final DailyStartModel dailyStartModel;

  //final

  CompleteAnalytics({
    super.key,
    required this.startedUser,
    this.endeduser,
    required this.dailyStartModel,
    required this.userModel,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: TextStyles.textHeadings(
                  textValue: 'Overview'.toUpperCase(),
                  textColor: AppColors.white),
            ),
            if (userModel.viewFinance)
              MetricsOverview(
                tenantId: startedUser.tenantId.trim(),
                dailyStartModel: dailyStartModel,
              ),
            if (userModel.voidingProducts || userModel.voidingTableOrder) ...[
              Padding(
                padding: EdgeInsets.all(8.0),
                child: TextStyles.textHeadings(
                    textValue: 'Voided Items'.toUpperCase(),
                    textColor: AppColors.white),
              ),
              VoidedOrdersPage(
                tenantId: startedUser.tenantId.trim(),
                dailyStartModel: dailyStartModel,
              ),
            ],
            if (userModel.viewFinance) ...[
              Padding(
                padding: EdgeInsets.all(8.0),
                child: TextStyles.textHeadings(
                    textValue: 'Payment Method'.toUpperCase(),
                    textColor: AppColors.white),
              ),
              CompletedOrdersByPayment(
                tenantId: startedUser.tenantId.trim(),
                dailyStartModel: dailyStartModel,
              ),
            ],
            if (userModel.viewFinance) ...[
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: TextStyles.textHeadings(
                    textValue: 'User Orders'.toUpperCase(),
                    textColor: AppColors.white),
              ),
              OrdersByUsersPage(
                tenantId: startedUser.tenantId.trim(),
                dailyStartModel: dailyStartModel,
              ),
            ],
            if (userModel.viewingLogs)
              SizedBox(
                height: 100, // Set a height to avoid an infinite scroll conflict
                child: UserLogsUI(
                  tenantId: startedUser.tenantId.trim(),
                  dailyStartModel: dailyStartModel,
                ),
              ),
            if (userModel.viewFinance) ...[
              Padding(
                padding: EdgeInsets.all(8.0),
                child: TextStyles.textHeadings(
                    textValue: 'Order Item Quantity'.toUpperCase(),
                    textColor: AppColors.white),
              ),
              RecentOrders(
                tenantId: startedUser.tenantId.trim(),
                dailyStartModel: dailyStartModel,
              ),
            ],

          ],
        ),
      ),
    );
  }
}
