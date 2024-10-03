import 'package:flutter/material.dart';
import 'package:pos_admin/view/widgets/app_custom_text.dart';

import '../res/app_colors.dart';
import '../res/app_images.dart';
import '../utills/app_utils.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  AppUtils appUtils = AppUtils();

  @override
  void initState() {
    appUtils.openApp(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.scaffoldBackgroundColor,
        body: Center(
          child: Container(
            // height: AppUtils.deviceScreenSize(context).height,
            // width: AppUtils.deviceScreenSize(context).width,
            decoration: const BoxDecoration(
              color: AppColors.scaffoldBackgroundColor,

              // image: DecorationImage(image: AssetImage(AppImages.splashLogo,),fit: BoxFit.fill)
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  AppImages.posTerminal,
                  width: 100,
                  height: 100,
                ),
                SizedBox(
                  height: 20,
                ),
                TextStyles.textHeadings(
                    textValue: "CHECKPOINT ADMIN POS",
                    textSize: 20,
                    textColor: AppColors.white)
              ],
            ),
          ),
        ));
  }
}
