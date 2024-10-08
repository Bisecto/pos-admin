import 'dart:async';
import 'package:idle_detector_wrapper/idle_detector_wrapper.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart' as modalSheet;

import 'package:cross_connectivity/cross_connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
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

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  int _currentIndex = 0;
  List<Widget> landPageScreens = [];
  bool _connected = true;

  StreamSubscription<ConnectivityStatus>? _connectivitySubscription;
  bool isNotification = false;

  @override
  void initState() {
    // TODO: implement initState

    // _checkConnectivity();
    // _connectivitySubscription =
    //     Connectivity().onConnectivityChanged.listen(_handleConnectivity);

    super.initState();
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
            drawer: ExampleSidebarX(controller: _controller),
            body: Row(
              children: [
                if (!isSmallScreen) ExampleSidebarX(controller: _controller),
                Expanded(
                  child: Center(child: PageSelector(controller: _controller)),
                ),
              ],
            ),
          )
        : Container(); //No_internet_Page(onRetry: _checkConnectivity);
  }
}

class ExampleSidebarX extends StatelessWidget {
  const ExampleSidebarX({
    Key? key,
    required SidebarXController controller,
  })  : _controller = controller,
        super(key: key);

  final SidebarXController _controller;

  @override
  Widget build(BuildContext context) {
    return IdleDetector(
      idleTime: const Duration(minutes: 10),
      onIdle: () async {
        AppNavigator.pushAndRemovePreviousPages(context, page: SignInScreen());
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
                  child: Image.asset(AppImages.posTerminal),
                ),
              );
            },
            items: [
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
              SidebarXItem(
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
              SidebarXItem(
                icon: Icons.logout,
                label: 'Logout',
                selectable: false,
                onTap: () {
                  AppNavigator.pushAndRemovePreviousPages(context,
                      page: SignInScreen());
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
      return 'Logout';
    case 7:
      return 'Settings';
    default:
      return 'Not found page';
  }
}
