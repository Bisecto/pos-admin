import 'package:flutter/material.dart';

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
        backgroundColor: AppColors.darkGreen,
        body: Container(
            height: AppUtils.deviceScreenSize(context).height,
            width: AppUtils.deviceScreenSize(context).width,
          decoration: const BoxDecoration(
              color: AppColors.darkGreen,

             // image: DecorationImage(image: AssetImage(AppImages.splashLogo,),fit: BoxFit.fill)
          ),
          child: const Icon(Icons.access_time_outlined,size: 70,),
        )
        // Image.asset(
        //   AppImages.splashLogo,
        //   height: AppUtils.deviceScreenSize(context).height,
        //   width: AppUtils.deviceScreenSize(context).width+50,
        // )
        // SvgPicture.asset(
        //   AppIcons.splashScreen,
        //   height: AppUtils.deviceScreenSize(context).height,
        //   width: AppUtils.deviceScreenSize(context).width,
        // ),
        // Container(
        //   height: AppUtils.deviceScreenSize(context).height,
        //   width: AppUtils.deviceScreenSize(context).width,
        //   decoration:  BoxDecoration(
        //       gradient: const LinearGradient(
        //         colors: [
        //           AppColors.lightGreen,
        //           AppColors.darkGreen,
        //           AppColors.lightGreen
        //         ],
        //         begin: Alignment.bottomLeft,
        //         end: Alignment.topRight,
        //       ),
        //       // image: DecorationImage(
        //       //     image: const AssetImage(
        //       //       AppImages.splashScreenFrame,
        //       //     ),
        //       //     fit: BoxFit.values[0])),
        //   child: Center(child:Image.asset(AppImages.fullLogo)),
        // )
        );
  }
}
