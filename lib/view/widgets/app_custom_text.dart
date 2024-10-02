
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../res/app_colors.dart';

class CustomText extends StatelessWidget {
  final String? text;
  final double? size;
  final Color? color;
  final FontWeight? weight;
  final TextAlign? textAlign;
  final double? spacing;
  final int maxLines;
  final bool underline;

  const CustomText({
    Key? key,
    this.text,
    this.size,
    this.color = AppColors.textColor,
    this.weight = FontWeight.w400,
    this.spacing = 0,
    this.textAlign = TextAlign.start,
    this.maxLines = 1,
    this.underline = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Text(text ?? '',
        textDirection: TextDirection.ltr,
        textAlign: textAlign,
        maxLines: maxLines,
        softWrap: true,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.poppins(
          //fontFamily: "CeraPro",
          decoration:
              (underline) ? TextDecoration.underline : TextDecoration.none,
          decorationColor: AppColors.green,
          letterSpacing: spacing!,
          fontSize: size != null ? (size! + 0.0) : 12,
          color: color ?? Colors.black,
          //   fontWeight: weight ?? FontWeight.normal,
        )
        // TextStyle(
        //   fontFamily: "CeraPro",
        //   decoration:
        //       (underline) ? TextDecoration.underline : TextDecoration.none,
        //   decorationColor: AppColors.green,
        //   letterSpacing: spacing!,
        //   fontSize: size ?? 16,
        //   color: color ?? Colors.black,
        //   fontWeight: weight ?? FontWeight.normal,
        // ),
        );
  }
}

class TextStyles {
  static textHeadings(
      {required String textValue,FontWeight fontWeight=FontWeight.w800, double textSize = 16, Color? textColor}) {
    return Text(
      textValue,
      textDirection: TextDirection.ltr,
      style: GoogleFonts.anybody(
        textStyle: TextStyle(
            fontStyle: FontStyle.normal,
            color: textColor,
            fontSize: textSize,

            fontWeight: fontWeight),
      ),
      textAlign: TextAlign.center,
    );
  }

  static textSubHeadings({
    required String textValue,
    double textSize = 14,
    Color? textColor,
    bool centerText = false,
  }) {
    return Text(
      textValue,
      textDirection: TextDirection.ltr,
      style: TextStyle(
          fontStyle: FontStyle.normal,
          color: textColor,
          fontSize: textSize,
          fontWeight: FontWeight.bold),
      textAlign: (centerText) ? TextAlign.center : TextAlign.start,
    );
  }

  static textDetails({
    required String textValue,
    double textSize = 12,
    double lineSpacing = 1.1,
    Color? textColor = Colors.white,
    bool centerText = false,
  }) {
    return Text(
      textValue,
      textDirection: TextDirection.ltr,
      textAlign: (centerText) ? TextAlign.center : TextAlign.start,
      //softWrap: true,
      maxLines: 3,
      softWrap: true,
      style: TextStyle(
          fontStyle: FontStyle.normal,
          color: textColor,
          fontSize: textSize,
          fontWeight: FontWeight.w400,

          height: lineSpacing),
    );
  }

  static richTexts(
      {String? text1,
      String? text2,
      double size = 16,
      String text3 = '',
      String text4 = '',
      String text5 = '',
      String text6 = '',
      String text7 = '',
      String text8 = '',
      String text9 = '',
      String text10 = '',
      FontWeight? weight = FontWeight.w400,
      Function? onPress1,
      bool centerText = false,
      Color? color2 = AppColors.green,
      Color? color5 = AppColors.green,
      Color? color6 = AppColors.green,
      Color? color7 = AppColors.green,
      Color? color8 = AppColors.green,
      Color? color9 = AppColors.green,
      Color? color10 = AppColors.green,
      Color? color = const Color.fromARGB(255, 73, 71, 71),
      TextDecoration decoration = TextDecoration.none,
      Function? onPress2}) {
    return RichText(
      textAlign: (centerText) ? TextAlign.center : TextAlign.justify,
      textDirection: TextDirection.ltr,
      softWrap: true,
      text: TextSpan(children: [
        TextSpan(
          text: text1,
          style: TextStyle(
              fontStyle: FontStyle.normal,
              color: color,
              fontSize: size,
              fontWeight: weight),
        ),
        TextSpan(
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              onPress1!();
            },
          text: text2,
          style: TextStyle(
              decoration: decoration,
              fontStyle: FontStyle.normal,
              color: color2,
              fontSize: size,
              fontWeight: weight),
        ),
        TextSpan(
          text: text3,
          style: TextStyle(
              fontStyle: FontStyle.normal,
              color: color,
              fontSize: size,
              fontWeight: weight),
        ),
        TextSpan(
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                onPress2!();
              },
            text: text4,
            style:
                TextStyle(color: color2, fontSize: size, fontWeight: weight)),
        TextSpan(
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                onPress2!();
              },
            text: text5,
            style:
                TextStyle(color: color5, fontSize: size, fontWeight: weight)),
        TextSpan(
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                onPress2!();
              },
            text: text6,
            style:
                TextStyle(color: color6, fontSize: size, fontWeight: weight)),
        TextSpan(
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                onPress2!();
              },
            text: text7,
            style:
                TextStyle(color: color7, fontSize: size, fontWeight: weight)),
        TextSpan(
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                onPress2!();
              },
            text: text8,
            style:
                TextStyle(color: color8, fontSize: size, fontWeight: weight)),
        TextSpan(
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                onPress2!();
              },
            text: text9,
            style:
                TextStyle(color: color9, fontSize: size, fontWeight: weight)),
        TextSpan(
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                onPress2!();
              },
            text: text10,
            style:
                TextStyle(color: color10, fontSize: size, fontWeight: weight)),
      ]),
    );
  }
}
