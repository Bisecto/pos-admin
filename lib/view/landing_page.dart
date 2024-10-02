import 'dart:async';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart' as modalSheet;

import 'package:cross_connectivity/cross_connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:sidebarx/sidebarx.dart';

import '../../main.dart';
import '../../res/app_colors.dart';
import '../../res/sharedpref_key.dart';
import '../../utills/app_navigator.dart';
import '../../utills/app_utils.dart';
import '../../utills/custom_theme.dart';
import '../../utills/enums/toast_mesage.dart';
import '../../utills/shared_preferences.dart';

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



    _checkConnectivity();
    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen(_handleConnectivity);


    super.initState();
  }

  Future<void> _checkConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    _handleConnectivity(connectivityResult);
  }

  void _handleConnectivity(ConnectivityStatus result) {
    if (result == ConnectivityStatus.none) {
      debugPrint("No network");
      setState(() {
        _connected = false;
      });
    } else {
      debugPrint("Network connected");
      setState(() {
        _connected = true;
      });
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider
        .of<CustomThemeState>(context)
        .adaptiveThemeMode;

    return _connected
        ? Scaffold(
      body: Row(
        children: [
          SidebarX(
            controller: SidebarXController(selectedIndex: 0),
            items: const [
              SidebarXItem(icon: Icons.home, label: 'Home'),
              SidebarXItem(icon: Icons.search, label: 'Search'),
            ],
          ),
          // Your app screen body
        ],
      ),
    )
        : Container();//No_internet_Page(onRetry: _checkConnectivity);
  }
}
