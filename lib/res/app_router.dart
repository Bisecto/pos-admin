import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../view/app_screens/auth/sign_in_screen.dart';
import '../view/important_pages/not_found_page.dart';
import '../view/app_screens/landing_page.dart';
import '../view/splash_screen.dart';

class AppRouter {
  ///All route name

  /// ONBOARDING SCREEEN
  static const String splashScreen = '/';

  /// AUTH SCREENS
  static const String signInScreen = "/sign-in-page";

  static const String noInternetScreen = "/no-internet";

  ///LANDING PAGE LandingPage
  //static const String landingPage = "/landing-page";

  // static const String homePage = "/home-page";

  //static const String airtime = '/airtime';

  Route onGenerateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case splashScreen:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case signInScreen:
        return MaterialPageRoute(builder: (_) => const SignInScreen());

      // case landingPage:
      //   return MaterialPageRoute(
      //     builder: (_) => const LandingPage(),
      //   );

      default:
        return MaterialPageRoute(builder: (_) => const NotFoundPage());
    }
  }
}
