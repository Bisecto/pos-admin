import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../res/app_colors.dart';
import '../../utills/app_utils.dart';
import '../../utills/custom_theme.dart';
import 'app_custom_text.dart';

class CustomAppBar extends StatelessWidget {
  final String title;
  final Color mainColor;
  final Color subColor;

  const CustomAppBar(
      {super.key,
      required this.title,
      this.subColor = AppColors.appBarSubColor,
      this.mainColor = AppColors.appBarMainColor});

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<CustomThemeState>(context).adaptiveThemeMode;

    return Container(
      height: 120,
      decoration: BoxDecoration(
          color: theme.isDark?AppColors.lightGreen:subColor,
          borderRadius:
              const BorderRadius.vertical(bottom: Radius.circular(30))),
      child: Column(
        children: [
          //SizedBox(height: 15,),
          Container(
            height: 100,
            width: AppUtils.deviceScreenSize(context).width,
            decoration: BoxDecoration(
                color:theme.isDark?AppColors.darkModeBackgroundColor: mainColor,
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(30))),
            child: Padding(
              padding: const EdgeInsets.only(left: 20.0,top: 20),
              child: Row(
                children: [
                 GestureDetector(onTap:(){
                  Navigator.pop(context);
                 },child: const Icon(Icons.arrow_back_ios)),
                  TextStyles.textHeadings(textValue: title,textColor: theme.isDark?AppColors.white:AppColors.black)
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
