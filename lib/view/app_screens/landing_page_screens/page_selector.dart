import 'package:flutter/material.dart';
import 'package:pos_admin/res/app_colors.dart';
import 'package:pos_admin/view/app_screens/landing_page_screens/products_page_screens/main_product_screen.dart';
import 'package:pos_admin/view/app_screens/landing_page_screens/role_page_screens/main_role_screen.dart';
import 'package:pos_admin/view/app_screens/landing_page_screens/tenant_profile/tenant_profile.dart';
import 'package:sidebarx/sidebarx.dart';

import '../../../model/tenant_model.dart';
import '../../widgets/app_custom_text.dart';
import 'brands_page_screens/main_brand_screen.dart';
import 'category_page_screens/main_category_screen.dart';
import 'orders/orders_placed.dart';

class PageSelector extends StatefulWidget {
  final SidebarXController controller;
  TenantModel tenantModel;


   PageSelector({super.key, required this.controller,required this.tenantModel});

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
                  return const MainProductScreen();
                case 1:
                  return const MainBrandScreen();
                case 2:
                  return const MainCategoryScreen();case 3:
                  return  OrderManagementPage(tenantId: '8V8YTiKWyObO7tppMHeP',);
                case 4:

                  return  MainUserScreen(tenantModel: widget.tenantModel,);case 5:
                  return  TenantProfilePage(tenantModel: widget.tenantModel,);
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
      return 'Settings';
    default:
      return 'Not found page';
  }
}
