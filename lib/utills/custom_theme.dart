import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';


class CustomThemeState extends ChangeNotifier {
  AdaptiveThemeMode adaptiveThemeMode = AdaptiveThemeMode.dark;

  CustomThemeState(this.adaptiveThemeMode);

  void changeTheme(context) async {
    if (adaptiveThemeMode.isSystem || adaptiveThemeMode.isLight) {
      AdaptiveTheme.of(context).setDark();
    } else {
      AdaptiveTheme.of(context).setLight();
    }
    final theme = await AdaptiveTheme.getThemeMode();
    adaptiveThemeMode = theme!;
    notifyListeners();
    //dPrint(theme);
  }
}
