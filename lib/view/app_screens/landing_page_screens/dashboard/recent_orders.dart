import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pos_admin/res/app_colors.dart';
import 'package:pos_admin/utills/app_utils.dart';
import 'package:pos_admin/view/widgets/form_button.dart';
import '../../../../model/order_model.dart';
import '../../../../model/start_stop_model.dart';
import '../../../widgets/app_custom_text.dart';
import 'order_list.dart';

class RecentOrders extends StatefulWidget {
  final String tenantId;
  final DailyStartModel dailyStartModel;

  RecentOrders({required this.tenantId,  required this.dailyStartModel});

  @override
  _RecentOrdersState createState() => _RecentOrdersState();
}

class _RecentOrdersState extends State<RecentOrders> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OrderList(
          tenantId: widget.tenantId,
          dailyStartModel: widget.dailyStartModel,
        ),
      ],
    );
  }
}
