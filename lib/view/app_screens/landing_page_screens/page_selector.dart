import 'package:flutter/material.dart';
import 'package:pos_admin/model/user_model.dart';
import 'package:pos_admin/res/app_colors.dart';
import 'package:pos_admin/view/app_screens/landing_page_screens/bank_details_page_screens/main_bank_screen.dart';
import 'package:pos_admin/view/app_screens/landing_page_screens/dashboard/main_dashboard_page.dart';
import 'package:pos_admin/view/app_screens/landing_page_screens/printer_setup_screens/main_printer_screen.dart';
import 'package:pos_admin/view/app_screens/landing_page_screens/products_page_screens/main_product_screen.dart';
import 'package:pos_admin/view/app_screens/landing_page_screens/role_page_screens/main_role_screen.dart';
import 'package:pos_admin/view/app_screens/landing_page_screens/settings/settings_page.dart';
import 'package:pos_admin/view/app_screens/landing_page_screens/tables_page_screen/main_table_screen.dart';
import 'package:pos_admin/view/app_screens/landing_page_screens/tenant_profile/tenant_profile.dart';
import 'package:sidebarx/sidebarx.dart';

import '../../../model/tenant_model.dart';
import '../../widgets/app_custom_text.dart';
import 'brands_page_screens/main_brand_screen.dart';
import 'category_page_screens/main_category_screen.dart';
import 'logs/log_page.dart';
import 'orders/orders_placed.dart';

class PageSelector extends StatefulWidget {
  final SidebarXController controller;
  TenantModel tenantModel;
  UserModel userModel;

  PageSelector(
      {super.key,
      required this.controller,
      required this.tenantModel,
      required this.userModel});

  @override
  State<PageSelector> createState() => _PageSelectorState();
}

class _PageSelectorState extends State<PageSelector> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pageTitle = _getTitleByIndex(widget.controller.selectedIndex);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      body: SafeArea(
        bottom: true,
        left: true,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: AnimatedBuilder(
            animation: widget.controller,
            builder: (context, child) {
              final pageTitle =
                  _getTitleByIndex(widget.controller.selectedIndex);
              switch (widget.controller.selectedIndex) {
                case 0:
                  return Dashboard(
                    tenantId: widget.userModel.tenantId,
                    userModel: widget.userModel,
                  );
                case 1:
                  return MainProductScreen(
                    userModel: widget.userModel,
                  );
                case 2:
                  return MainBrandScreen(
                    userModel: widget.userModel,
                  );
                case 3:
                  return MainCategoryScreen(
                    userModel: widget.userModel,
                  );
                case 4:
                  return MainTableScreen(
                    userModel: widget.userModel,
                    tenantModel: widget.tenantModel,
                  );
                case 5:
                  return OrderManagementPage(
                    tenantId: widget.userModel.tenantId,
                    tenantModel: widget.tenantModel,
                    userModel: widget.userModel,
                  );
                case 6:
                  return MainUserScreen(
                    tenantModel: widget.tenantModel,
                    userModel: widget.userModel,
                  );
                case 7:
                  return TenantProfilePage(
                    tenantModel: widget.tenantModel,
                    userModel: widget.userModel,
                  );
                case 8:
                  return const SettingsPage();
                case 9:
                  return MainPrinterScreen(
                    userModel: widget.userModel,
                  );
                case 10:
                  return LogUI(
                    tenantId: widget.userModel.tenantId.trim(),
                  );
                case 11:
                  return MainBankScreen(
                    userModel: widget.userModel,
                  );
                default:
                  return TextStyles.textHeadings(
                    textValue: pageTitle,
                    textSize: 25, textColor: AppColors.white,
                    //style: theme.textTheme.headlineSmall,
                  );
              }
            },
          ),
        ),
      ),
    );
  }
}

String _getTitleByIndex(int index) {
  switch (index) {
    case 0:
      return 'Products';
    case 1:
      return 'Brands';
    case 2:
      return 'Category';
    case 3:
      return 'Invoices';
    case 4:
      return 'Roles';
    case 5:
      return 'Profile';
    case 6:
      return 'Change Password';
    default:
      return 'Not found page';
  }
}
