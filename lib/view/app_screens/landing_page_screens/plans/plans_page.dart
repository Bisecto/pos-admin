import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pos_admin/model/tenant_model.dart';
import 'package:pos_admin/utills/app_utils.dart';
import 'package:pos_admin/view/widgets/form_button.dart';

import '../../../../model/plan_model.dart';
import '../../../../model/user_model.dart';
import '../../../../res/app_colors.dart';

class PlansPage extends StatefulWidget {
  final UserModel userModel;
  final TenantModel tenantModel;
  final List<Plan> plans;

  PlansPage({
    super.key,
    required this.userModel,
    required this.tenantModel, required this.plans,
  });

  @override
  State<PlansPage> createState() => _PlansPageState();
}

class _PlansPageState extends State<PlansPage> {
  Stream<List<Map<String, dynamic>>> fetchPlans() {
    return FirebaseFirestore.instance
        .collection('plans')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<String> planOrder = ['starter', 'basic', 'growth', 'enterprise'];

    // Sort the plans based on the custom order
    final sortedPlans = widget.plans
        .where((plan) => planOrder.contains(plan.name.toLowerCase()))
        .toList()
      ..sort((a, b) {
        return planOrder.indexOf(a.name.toLowerCase()) -
            planOrder.indexOf(b.name.toLowerCase());
      });

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            childAspectRatio: 0.4,
            crossAxisSpacing: 5,
            mainAxisSpacing: 5,
          ),
          itemCount: sortedPlans.length,
          itemBuilder: (context, index) {
            return PlanCard(
              plan: sortedPlans[index],
              userModel: widget.userModel,
              tenantModel: widget.tenantModel,
            );
          },
        ),
      ),
    );
  }
}

class PlanCard extends StatelessWidget {
  final UserModel userModel;
  final TenantModel tenantModel;
  final Plan plan;

  const PlanCard({
    super.key,
    required this.plan,
    required this.userModel,
    required this.tenantModel,
  });

  @override
  Widget build(BuildContext context) {
    final planName = plan.name.toString();
    final isCurrentPlan =
        planName.toLowerCase() == tenantModel.subscriptionPlan.toLowerCase();

    final features = <String>[
      "🛒 Max Products: ${plan.maxProducts == -1 ? 'Unlimited' : plan.maxProducts}",
      "💰 Max Transactions: ${plan.maxTransactionsPerMonth == -1 ? 'Unlimited' : plan.maxTransactionsPerMonth}",
      "👥 Max Users: ${plan.maxUsers == -1 ? 'Unlimited' : plan.maxUsers}",
      statusFeature(plan.cloudSync, "Cloud Sync", "☁️"),
      statusFeature(plan.exportProductsToExcel, "Export Products to Excel", "📦"),
      statusFeature(plan.exportTransactionsToExcel, "Export Transactions to Excel", "📊"),
      statusFeature(plan.exportStaffToExcel, "Export Staff to Excel", "📋"),
      statusFeature(plan.accessToMultiTerminal, "Multi-Terminal Access", "🔌"),
      statusFeature(plan.offlineMode, "Offline Mode", "📴"),
      statusFeature(plan.customBranding, "Custom Branding", "🎨"),
      statusFeature(plan.advancedRolesBranding, "Advanced Roles & Branding", "🔐"),
      statusFeature(plan.apiAccess, "API Access", "🔗"),
      statusFeature(plan.stockManagement, "Stock Management", "📦"),
      statusFeature(plan.logs, "Activity Logs", "📑"),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkModeBackgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCurrentPlan ? AppColors.green : AppColors.darkYellow,
        ),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 4)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              planName,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isCurrentPlan ? AppColors.green : AppColors.darkYellow,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "₦${AppUtils.convertPrice(plan.monthlyPrice)}/month",
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
            Text(
              "₦${AppUtils.convertPrice(plan.yearlyPrice)}/year",
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const Divider(height: 20),
            Expanded(
              child: ListView(
                children: features
                    .map((f) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: Text(
                    "• $f",
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.white,
                    ),
                  ),
                ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 8),
            FormButton(
              onPressed: (){},
              // onPressed: isCurrentPlan
              //     ? null
              //     : () async {
              //   await FirebaseFirestore.instance
              //       .collection('Enrolled Entities')
              //       .doc(userModel.tenantId.trim())
              //       .update({
              //     'subscriptionPlan': planName,
              //     'subscriptionStart': FieldValue.serverTimestamp(),
              //     'subscriptionEnd': DateTime.now().add(
              //       const Duration(days: 30),
              //     ),
              //     'isSubscriptionActive': true,
              //   });
              // },
              bgColor: isCurrentPlan
                  ? AppColors.green
                  : AppColors.darkYellow,
              disableButton: isCurrentPlan,
              text: isCurrentPlan ? "Subscribed" : "Subscribe",
            ),
          ],
        ),
      ),
    );
  }

  String statusFeature(bool value, String label, String emoji) {
    return value ? "$emoji $label - Included" : "❌ $label - Not included";
  }
}
