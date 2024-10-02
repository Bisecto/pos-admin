// import 'package:buygas/models/user_model.dart';
// import 'package:buygas/view/mobile_view/landing_screens/home/account_page.dart';
// import 'package:buygas/view/mobile_view/landing_screens/home/history_page.dart';
// import 'package:buygas/view/mobile_view/landing_screens/home/home_page.dart';
// import 'package:flutter/material.dart';
//
// class TabNavigatorRoutes {
//   static const String root = '/';
//   static const String detail = '/detail';
// }
//
// class TabNavigator extends StatefulWidget {
//   const TabNavigator({super.key,  required this.navigatorKey, required this.tabItem,required this.userModel});
//
//   final GlobalKey<NavigatorState> navigatorKey;
//   final String tabItem;
//   final UserModel userModel;
//
//
//   @override
//   State<TabNavigator> createState() => _TabNavigatorState();
// }
//
// class _TabNavigatorState extends State<TabNavigator> {
//   @override
//   Widget build(BuildContext context) {
//     late Widget child;
//     if (widget.tabItem == "Home") {
//       setState(() {
//         child = const HomePage();
//       });
//     } else if (widget.tabItem == "History") {
//       setState(() {
//         child = const HistoryPage();
//       });
//     }
//     else if (widget.tabItem == "Account") {
//       setState(() {
//         child =  AccountPage(userModel: widget.userModel, navigatorKey: widget.navigatorKey,);
//       });
//     }
//
//     return Navigator(
//       key: widget.navigatorKey,
//       onGenerateRoute: (routeSettings) {
//         return MaterialPageRoute(
//             builder: (context) => child
//         );
//       },
//     );
//   }
// }