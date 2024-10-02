import 'package:flutter/material.dart';
import 'package:pos_admin/res/app_colors.dart';
import 'package:pos_admin/view/app_screens/landing_page_screens/products_page_screens/main_product_screen.dart';
import 'package:sidebarx/sidebarx.dart';

import '../../widgets/app_custom_text.dart';

class PageSelector extends StatefulWidget {
  final SidebarXController controller;

  const PageSelector({super.key,required this.controller});

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
              final pageTitle = _getTitleByIndex(widget.controller.selectedIndex);
              switch (widget.controller.selectedIndex) {
                case 0:
                  return const MainProductScreen();
                default:
                  return TextStyles.textHeadings(
                    textValue:pageTitle,
                    textSize: 25,textColor: AppColors.white,
                    //style: theme.textTheme.headlineSmall,
                  );
              }
            },
          ),
        ),
      ),
    );  }
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
      return 'Suppliers';
    case 5:
      return 'Profile';
    case 6:
      return 'Settings';
    default:
      return 'Not found page';
  }
}
