import 'dart:io';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';

import 'package:pos_admin/res/app_router.dart';
import 'package:pos_admin/utills/custom_theme.dart';
import 'package:pos_admin/view/splash_screen.dart';
import 'package:provider/provider.dart';


// Remove the redundant import of `firebase_core.dart` here



void main() async {
  WidgetsFlutterBinding.ensureInitialized();







  runApp(
    MyApp(),
  );
}

class MyApp extends StatelessWidget {

  MyApp({Key? key,}) : super(key: key);

  final AppRouter _appRoutes = AppRouter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UNIZIK Portal',
      debugShowCheckedModeBanner: false,
      onGenerateRoute: _appRoutes.onGenerateRoute,
      //theme: theme,
      //darkTheme: darkTheme,
      home: const SplashScreen(),
    );
  }
}
