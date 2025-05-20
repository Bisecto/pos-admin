import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:idle_detector_wrapper/idle_detector_wrapper.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart' as modalSheet;

import 'package:cross_connectivity/cross_connectivity.dart';
import 'package:flutter/material.dart';
import 'package:pos_admin/model/tenant_model.dart';
import 'package:pos_admin/model/user_model.dart';
import 'package:pos_admin/res/app_images.dart';
import 'package:pos_admin/view/app_screens/auth/sign_in_screen.dart';
import 'package:pos_admin/view/app_screens/landing_page_screens/page_selector.dart';
import 'package:provider/provider.dart';
import 'package:sidebarx/sidebarx.dart';

import '../../../main.dart';
import '../../../res/app_colors.dart';
import '../../../res/sharedpref_key.dart';
import '../../../utills/app_navigator.dart';
import '../../../utills/app_utils.dart';
import '../../../utills/custom_theme.dart';
import '../../../utills/enums/toast_mesage.dart';
import '../../../utills/shared_preferences.dart';
import '../../model/plan_model.dart';
import '../widgets/app_custom_text.dart';

class LandingPage extends StatefulWidget {
  TenantModel tenantModel;
  UserModel userModel;
  final List<Plan> plans;


  LandingPage({super.key, required this.tenantModel, required this.userModel, required this.plans});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  int _currentIndex = 0;
  List<Widget> landPageScreens = [];
  bool _connected = true;

  StreamSubscription<ConnectivityStatus>? _connectivitySubscription;
  bool isNotification = false;
  String pt = '';

  @override
  void initState() {
    // TODO: implement initState
    getPt();
    // _checkConnectivity();
    // _connectivitySubscription =
    //     Connectivity().onConnectivityChanged.listen(_handleConnectivity);

    super.initState();
  }

  getPt() async {
    pt = await SharedPref.getString('password');
    print(pt);
    if (pt == 'Qwerty123@') {
      showEditPopup(context);
      //print("Change password");
    }
  }

  void showEditPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            width: 300,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                const BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Change password',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                CustomText(
                  text: "You are mandated to change your password",
                  maxLines: 3,
                )
              ],
            ),
          ),
        );
      },
    );
  }

  // Future<void> _checkConnectivity() async {
  //   var connectivityResult = await Connectivity().checkConnectivity();
  //   _handleConnectivity(connectivityResult);
  // }

  // void _handleConnectivity(ConnectivityStatus result) {
  //   if (result == ConnectivityStatus.none) {
  //     debugPrint("No network");
  //     setState(() {
  //       _connected = false;
  //     });
  //   } else {
  //     debugPrint("Network connected");
  //     setState(() {
  //       _connected = true;
  //     });
  //   }
  // }

  // @override
  // void dispose() {
  //   _connectivitySubscription?.cancel();
  //   super.dispose();
  // }
  final _controller = SidebarXController(selectedIndex: 0, extended: true);
  final _key = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return _connected
        ? Scaffold(
            key: _key,
            appBar: isSmallScreen
                ? AppBar(
                    backgroundColor: AppColors.canvasColor,
                    title: Text(_getTitleByIndex(_controller.selectedIndex)),
                    leading: IconButton(
                      onPressed: () {
                        // if (!Platform.isAndroid && !Platform.isIOS) {
                        //   _controller.setExtended(true);
                        // }
                        _key.currentState?.openDrawer();
                      },
                      icon: const Icon(Icons.menu),
                    ),
                  )
                : null,
            drawer: ExampleSidebarX(controller: _controller, tenantModel: widget.tenantModel,),
            body: Row(
              children: [
                if (!isSmallScreen) ExampleSidebarX(controller: _controller, tenantModel: widget.tenantModel,),
                Expanded(
                  child: Center(
                      child: PageSelector(
                    controller: _controller,
                    tenantModel: widget.tenantModel,
                    userModel: widget.userModel, plans: widget.plans,
                  )),
                ),
              ],
            ),
          )
        : Container(); //No_internet_Page(onRetry: _checkConnectivity);
  }
}

class ExampleSidebarX extends StatelessWidget {
  final TenantModel tenantModel;
  const ExampleSidebarX({
    Key? key,
    required SidebarXController controller, required this.tenantModel,
  })  : _controller = controller,
        super(key: key);

  final SidebarXController _controller;

  @override
  Widget build(BuildContext context) {
    return IdleDetector(
      idleTime: const Duration(minutes: 10),
      onIdle: () async {
        await FirebaseAuth.instance.signOut();
        AppNavigator.pushAndRemovePreviousPages(context,
            page: const SignInScreen());
      },
      child: Container(
        color: AppColors.scaffoldBackgroundColor,
        child: SafeArea(
          child: SidebarX(
            controller: _controller,
            theme: SidebarXTheme(
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.canvasColor,
                borderRadius: BorderRadius.circular(20),
              ),
              hoverColor: AppColors.scaffoldBackgroundColor,
              textStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
              selectedTextStyle: const TextStyle(color: Colors.white),
              hoverTextStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
              itemTextPadding: const EdgeInsets.only(left: 30),
              selectedItemTextPadding: const EdgeInsets.only(left: 30),
              itemDecoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.canvasColor),
              ),
              selectedItemDecoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.actionColor.withOpacity(0.37),
                ),
                gradient: const LinearGradient(
                  colors: [AppColors.accentCanvasColor, AppColors.canvasColor],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.28),
                    blurRadius: 30,
                  )
                ],
              ),
              iconTheme: IconThemeData(
                color: Colors.white.withOpacity(0.7),
                size: 20,
              ),
              selectedIconTheme: const IconThemeData(
                color: Colors.blue,
                size: 20,
              ),
            ),
            extendedTheme: const SidebarXTheme(
              width: 200,
              decoration: BoxDecoration(
                color: AppColors.canvasColor,
              ),
            ),
            footerDivider: AppColors.divider,
            headerBuilder: (context, extended) {
              return SizedBox(
                height: 100,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Image.network(tenantModel.logoUrl),
                ),
              );
            },
            items: [
              SidebarXItem(
                icon: Icons.dashboard,
                label: 'Dashboard',
                onTap: () {
                  //debugPrint('Products');
                },
              ),
              SidebarXItem(
                icon: Icons.storage,
                label: 'Products',
                onTap: () {
                  debugPrint('Products');
                },
              ),
              const SidebarXItem(
                icon: Icons.store,
                label: 'Brands',
              ),
              const SidebarXItem(
                icon: Icons.category,
                label: 'Category',
              ),
              const SidebarXItem(
                icon: Icons.table_restaurant_rounded,
                label: 'Tables',
                //selectable: false,
                //onTap: () => _showDisabledAlert(context),
              ),
              const SidebarXItem(
                icon: Icons.inventory_rounded,
                label: 'Invoice',
                //selectable: false,
                //onTap: () => _showDisabledAlert(context),
              ),
              const SidebarXItem(
                icon: Icons.people,
                label: 'Roles',
              ),
              const SidebarXItem(
                icon: Icons.person,
                label: 'Profile',
              ),
              const SidebarXItem(
                icon: Icons.password,
                label: 'Change Password',
              ),
              const SidebarXItem(
                icon: Icons.print,
                label: 'Printers',
              ),
              // const SidebarXItem(
              //   icon: Icons.details_outlined,
              //   label: 'Logs',
              // ),
               const SidebarXItem(
                icon: Icons.food_bank,
                label: 'Bank Details',
              ),const SidebarXItem(
                icon: Icons.local_attraction_outlined,
                label: 'Plans',
              ),
              SidebarXItem(
                icon: Icons.logout,
                label: 'Logout',
                selectable: false,
                onTap: () {
                  AppNavigator.pushAndRemovePreviousPages(context,
                      page: const SignInScreen());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDisabledAlert(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Item disabled for selecting',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
      ),
    );
  }
}

String _getTitleByIndex(int index) {
  switch (index) {
    case 0:
      return 'Dashboard';
    case 1:
      return 'Products';
    case 2:
      return 'Brands';
    case 3:
      return 'Category';
    case 4:
      return 'Tables';
    case 5:
      return 'Invoices';
    case 6:
      return 'Roles';
    case 7:
      return 'Profile';
    case 8:
      return 'Change Password';
    case 9:
      return 'Printers';
    // case 10:
    //   return 'Logs';
    case 10:
      return 'Bank Details'; case 11:
      return 'Plans';
    case 12:
      return 'Logout';

    default:
      return 'Not found page';
  }
}
