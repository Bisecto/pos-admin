import 'dart:io';

import 'package:flutter/material.dart';

import '../../res/app_colors.dart';

class AppRequestLoaderWidget extends StatelessWidget {
  final bool isItForSplashScreen;
  final double size;
  final bool checkPlatform;
  final AlignmentDirectional alignWidgetTo;
  const AppRequestLoaderWidget({
    super.key,
    this.isItForSplashScreen = false,
    this.checkPlatform = true,
    this.size = 36.0,
    this.alignWidgetTo = AlignmentDirectional.center,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignWidgetTo,
      child: SizedBox(
        width: checkPlatform
            ? Platform.isIOS
                ? null
                : size
            : size,
        height: checkPlatform
            ? Platform.isIOS
                ? null
                : size
            : size,
        child: CircularProgressIndicator.adaptive(
          backgroundColor: isItForSplashScreen
              ? AppColors.white
              : AppColors.lightPrimaryGreen,
          valueColor: AlwaysStoppedAnimation(
            isItForSplashScreen ? AppColors.lightPrimaryGreen : AppColors.white,
          ),
        ),
      ),
    );
  }
}
