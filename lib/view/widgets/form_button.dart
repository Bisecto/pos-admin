// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';

import '../../res/app_colors.dart';

class FormButton extends StatelessWidget {
  final String text;
  final Color? bgColor;
  final Function() onPressed;
  final Color borderColor;
  final IconData? iconWidget;
  final Color textColor;
  final double borderWidth;
  final double borderRadius;
  final double width;
  final double height;
  final double textSize;
  final bool disableButton;
  final FontWeight weight;
  final bool isIcon;

  const FormButton({
    Key? key,
    this.isIcon = false,
    this.iconWidget,
    this.text = '',
    this.textSize = 16,
    required this.onPressed,
    this.bgColor = AppColors.darkGreen,
    this.textColor = AppColors.white,
    this.disableButton = false,
    this.width = double.infinity,
    this.height = 48,
    this.weight = FontWeight.w600,
    this.borderColor = Colors.transparent,
    this.borderWidth = 0,
    this.borderRadius = 4,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 24, 0, 0),
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(borderRadius),
        ),
        border: Border.all(
          color: (!disableButton) ? borderColor : Colors.transparent,
          width: borderWidth,
        ),
      ),
      child: ElevatedButton(
        onPressed: (disableButton) ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: (disableButton)
              ? AppColors.grey // Grey color for disabled button
              : bgColor,
          fixedSize: const Size(double.infinity, 48),
          textStyle: TextStyle(
            fontSize: textSize,
            fontWeight: weight,
            color: textColor,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isIcon) Icon(iconWidget, color: textColor),
            if (isIcon)
              const SizedBox(
                width: 10,
              ),
            Text(
              text,
              style: TextStyle(
                fontFamily: "CeraPro",
                fontSize: textSize,
                fontWeight: weight,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FormBorderButton extends StatelessWidget {
  final String text;
  final Color? bgColor;
  final Color? txtColor;
  final Function() onPressed;
  final double width;

  const FormBorderButton(
      {Key? key,
      this.text = '',
      required this.onPressed,
      this.bgColor,
      this.width = double.infinity,
      this.txtColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 24, 0, 0),
      width: width,
      height: 42,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black54,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: bgColor,
          fixedSize: const Size(double.infinity, 35),
          textStyle: TextStyle(
              fontSize: 14, fontWeight: FontWeight.w300, color: txtColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        child: Center(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontFamily: "CeraPro",
                fontSize: 12,
                fontWeight: FontWeight.w300,
                color: txtColor),
          ),
        ),
      ),
    );
  }
}

class FormIconButton extends StatelessWidget {
  final String text;
  final Color? bgColor;
  final Function()? onPressed;
  final double width;
  final double height;
  final double fontSize;
  final bool hasIcon;
  final double marginTop;

  const FormIconButton(
      {Key? key,
      this.text = '',
      required this.onPressed,
      this.marginTop = 24,
      this.bgColor,
      this.height = 35,
      this.width = double.infinity,
      this.fontSize = 14,
      this.hasIcon = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.fromLTRB(0, marginTop, 0, 0),
        width: width,
        height: height,
        child: Directionality(
            textDirection: TextDirection.rtl,
            child: ElevatedButton.icon(
              icon: Icon(
                Icons.arrow_back,
                size: hasIcon ? 12 : 0,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: bgColor ?? AppColors.green,
                fixedSize: const Size(double.infinity, 48),
                textStyle:
                    TextStyle(fontSize: fontSize, fontWeight: FontWeight.w100),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              label: Text(
                text,
                style: TextStyle(
                    fontFamily: "CeraPro",
                    fontSize: fontSize,
                    fontWeight: FontWeight.w100),
              ),
              onPressed: onPressed,
            )));
  }
}
