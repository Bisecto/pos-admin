import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../res/app_colors.dart';
import '../../utills/custom_theme.dart';
import 'app_custom_text.dart';

class CustomContainerFirTitleDesc extends StatelessWidget {
  final String title;
  final String description;

  const CustomContainerFirTitleDesc(
      {super.key, required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<CustomThemeState>(context).adaptiveThemeMode;

    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Container(

        decoration: BoxDecoration(
          color: !theme.isDark?AppColors.white:AppColors.darkModeBackgroundContainerColor,
            borderRadius: BorderRadius.circular(15),
          border: Border.all(color: AppColors.textColor)
            ),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: title,
                    weight: FontWeight.bold,
                    maxLines: 3,
                    size: 14,
                    color: theme.isDark?AppColors.white:AppColors.darkModeBackgroundContainerColor,
                  ),
                  CustomText(
                    text: description,
                    maxLines: 3,
                    size: 12,
                    color: theme.isDark?AppColors.textColor:AppColors.darkModeBackgroundContainerColor,
                  )
                ],
              ),
               Icon(
                Icons.arrow_forward_ios,
                color: theme.isDark?AppColors.white:AppColors.darkModeBackgroundContainerColor,
              )
            ],
          ),
        ),
      ),
    );
  }
}

class CustomContainerFirTitleDescIcon extends StatelessWidget {
  final String title;
  final String description;
  final Widget iconData;

  const CustomContainerFirTitleDescIcon(
      {super.key,
      required this.title,
      required this.description,
      required this.iconData});

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<CustomThemeState>(context).adaptiveThemeMode;

    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Container(
        decoration: BoxDecoration(
          color: theme.isDark?AppColors.darkModeBackgroundContainerColor:AppColors.grey,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color:theme.isDark?AppColors.darkModeBackgroundContainerColor: AppColors.grey)),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            //mainAxisAlignment: MainAxisAlignment.,

            children: [
              iconData,
              const SizedBox(
                width: 10,
              ),
              Container(
                //width: double.maxFinite,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          text: title,
                          weight: FontWeight.bold,
                          maxLines: 3,
                          size: 12,
                          color: theme.isDark?AppColors.darkModeBackgroundMainTextColor:AppColors.black,
                        ),
                        CustomText(
                          text: description,
                          size: 12,
                          maxLines: 3,
                          color: theme.isDark?AppColors.darkModeBackgroundMainTextColor:AppColors.black,

                        )
                      ],
                    ),
                    // const Icon(
                    //   Icons.arrow_forward_ios,
                    //   color: AppColors.grey,
                    // )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomContainerForToggle extends StatelessWidget {
  final String title;
  final String description;
  final bool isSwitched;
  final Function(bool) toggleSwitch;

  const CustomContainerForToggle(
      {super.key,
      required this.title,
      required this.description,
      required this.isSwitched,
      required this.toggleSwitch});

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<CustomThemeState>(context).adaptiveThemeMode;

    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Container(
        decoration: BoxDecoration(
            color: !theme.isDark?AppColors.white:AppColors.darkModeBackgroundContainerColor,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: AppColors.grey)),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: title,
                    weight: FontWeight.bold,
                    maxLines: 3,
                    color: theme.isDark?AppColors.white:AppColors.darkModeBackgroundContainerColor,

                  ),
                  CustomText(
                    text: description,
                    maxLines: 3,
                    size: 12,
                    color: theme.isDark?AppColors.textColor:AppColors.darkModeBackgroundContainerColor,

                  ),
                ],
              ),
              Switch(
                value: isSwitched,
                onChanged: toggleSwitch,
                activeTrackColor: AppColors.lightShadowGreenColor,
                activeColor: AppColors.green,
              )
            ],
          ),
        ),
      ),
    );
  }
}

class CustomContainerWithIcon extends StatelessWidget {
  final String title;
  final Widget iconData;

  const CustomContainerWithIcon({
    super.key,
    required this.title,
    required this.iconData,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<CustomThemeState>(context).adaptiveThemeMode;

    return Padding(
      padding: const EdgeInsets.only(top: 15.0),
      child: Container(
        decoration: BoxDecoration(
            color: theme.isDark?AppColors.darkModeBackgroundColor:AppColors.lightPrimary,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: AppColors.grey)),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            //mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              iconData,
              const SizedBox(
                width: 15,
              ),
              CustomText(
                text: title,
                maxLines: 3,
                weight: FontWeight.w500,
                color: theme.isDark?AppColors.white:AppColors.black,

              ),
            ],
          ),
        ),
      ),
    );
  }
}
class CustomContainerWithRightIcon extends StatelessWidget {
  final String title;

  const CustomContainerWithRightIcon({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<CustomThemeState>(context).adaptiveThemeMode;

    return Padding(
      padding: const EdgeInsets.only(top: 15.0),
      child: Container(
        decoration: BoxDecoration(
            color: theme.isDark?AppColors.darkModeBackgroundContainerColor:AppColors.lightPrimary,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color:  theme.isDark?AppColors.darkModeBackgroundContainerColor:AppColors.grey)),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              CustomText(
                text: title,
                maxLines: 3,
                weight: FontWeight.w500,
                size: 14,
                color:theme.isDark?AppColors.white:AppColors.black
              ),
              const Icon(Icons.arrow_forward_ios,color: AppColors.grey)
            ],
          ),
        ),
      ),
    );
  }
}
