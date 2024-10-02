import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../res/app_colors.dart';
import '../../utills/custom_theme.dart';
import 'app_custom_text.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../res/app_colors.dart';
import '../../utills/custom_theme.dart';
import 'app_custom_text.dart';

class CustomTextFormField extends StatefulWidget {
  final bool isobscure;
  final bool isMobileNumber;
  final ValueChanged<String>? onChanged;
  final Function? onFieldSubmitted;
  final String? Function(String?)? validateName;
  final String hint;
  final String label;
  final int? maxLines;
  final bool isPasswordField;
  final int? maxLength;
  final double borderRadius;
  final double width;

  final Widget? widget;
  final Widget? suffixIcon;
  final Color borderColor;
  final TextInputType textInputType;
  final TextEditingController? controller;
  final bool? enabled;
  final FormFieldValidator<String>? validator;
  final Color backgroundColor;

  const CustomTextFormField({
    super.key,
    this.maxLength,
    this.maxLines = 1,
    this.borderRadius = 10,
    required this.width,
    this.textInputType = TextInputType.text,
    this.widget,
    this.suffixIcon,
    this.backgroundColor = AppColors.white,
    this.borderColor = AppColors.grey,
    this.isPasswordField = false,
    required this.controller,
    this.validateName,
    this.validator,
    this.isMobileNumber = false,
    this.isobscure = true,
    this.enabled = true,
    this.onChanged,
    this.onFieldSubmitted,
    required this.hint,
    required this.label,
  });

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  bool _obscureText = false;

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          text: widget.label,
          color: AppColors.darkModeBackgroundMainTextColor,
          size: 12,
        ),
        if (widget.label != '')
          const SizedBox(
            height: 10,
          ),
        Container(
          width: widget.width,
          decoration: BoxDecoration(
            color: AppColors.scaffoldBackgroundColor,
            border: Border.all(
              color: widget.borderColor,
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (widget.isMobileNumber)
                  const Text(
                    '+234',
                    style: TextStyle(
                      fontSize: 15,
                    ),
                  ),
                if (widget.isMobileNumber) const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: widget.controller,
                    enabled: widget.enabled,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.white,
                    ),
                    decoration: InputDecoration(
                      prefixIcon: widget.widget != null
                          ? Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: GestureDetector(
                                onTap: () {
                                  if (widget.isPasswordField) {
                                    _togglePasswordVisibility();
                                  }
                                },
                                child: widget.widget,
                              ),
                            )
                          : null,
                      suffixIcon: GestureDetector(
                        onTap: () {
                          if (widget.isPasswordField) {
                            _togglePasswordVisibility();
                          }
                        },
                        child: widget.suffixIcon ??
                            Icon(
                              widget.isPasswordField
                                  ? (_obscureText
                                      ? Icons.visibility
                                      : Icons.visibility_off)
                                  : null,
                            ),
                      ),
                      hintText: widget.hint,
                      hintStyle: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.textColor2,
                      ),
                      border: InputBorder.none,
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 15.0),
                    ),
                    keyboardType: widget.textInputType,
                    validator: widget.validator,
                    maxLines: widget.maxLines,
                    maxLength: widget.maxLength,
                    obscureText: widget.isPasswordField ? _obscureText : false,
                    onFieldSubmitted: (val) {
                      widget.onFieldSubmitted?.call(val);
                    },
                    onChanged: (val) {
                      if (widget.onChanged != null) {
                        widget.onChanged!(val);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class CustomTextFormPasswordField extends StatefulWidget {
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validateName;
  final String label;
  final TextEditingController controller;

  const CustomTextFormPasswordField({
    super.key,
    required this.controller,
    this.validateName,
    this.onChanged,
    required this.label,
  });

  @override
  State<CustomTextFormPasswordField> createState() =>
      _CustomTextFormPasswordFieldState();
}

class _CustomTextFormPasswordFieldState
    extends State<CustomTextFormPasswordField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: widget.label,
      ),
      keyboardType: TextInputType.text,
      validator: widget.validateName,
      onChanged: (String val) {
        // Handle change
      },
    );
  }
}

class FormInput extends StatelessWidget {
  final bool isobscure;
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final FocusNode? focusNode;
  final String label;
  final String hint;
  final String? value;
  final TextInputType inputType;
  final List<TextInputFormatter>? textInputFormatter;
  final int maxLines;
  final double width;
  final double height;
  final bool isEnabled;
  final bool topSpace;
  final int? maxLength;
  final Color? color;
  final Color? txColor;
  final Color? borderColor;
  final Function()? onTap;
  final Function(String)? validate;

  const FormInput({
    Key? key,
    this.onChanged,
    this.focusNode,
    required this.controller,
    this.label = '',
    this.topSpace = true,
    this.isobscure = false,
    this.hint = '',
    this.value,
    this.width = 200,
    this.color,
    this.txColor,
    this.height = 42,
    this.inputType = TextInputType.text,
    this.maxLines = 1,
    this.onTap,
    this.maxLength,
    this.isEnabled = true,
    this.validate,
    this.borderColor,
    this.textInputFormatter,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    controller.text = value != '' && value != null ? value! : controller.text;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        if (topSpace)
          Text(
            label,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87),
          ),
        if (topSpace) const SizedBox(height: 8),
        Material(
          color: color ?? Colors.black12,
          elevation: 0,
          type: MaterialType.card,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(4)),
          ),
          child: Align(
            alignment: Alignment.topLeft,
            child: TextField(
              obscureText: isobscure,
              controller: controller,
              keyboardType: inputType,
              maxLines: maxLines,
              enabled: isEnabled,
              focusNode: focusNode,
              inputFormatters: textInputFormatter,
              style: TextStyle(color: txColor ?? Colors.black87),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.fromLTRB(8, height >= 48 ? 8 : 2, 8, 8),
                hintText: hint,
                hintStyle: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 16,
                    overflow: TextOverflow.visible),
              ),
              onChanged: (text) {
                if (onChanged != null) {
                  onChanged!(text);
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}

class FormSelectInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final TextInputType inputType;
  final int maxLines;
  final double width;
  final double height;
  final bool isEnabled;

  const FormSelectInput({
    Key? key,
    required this.controller,
    this.label = '',
    this.hint = '',
    this.width = 200,
    this.height = 35,
    this.inputType = TextInputType.text,
    this.maxLines = 1,
    this.isEnabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        Material(
          color: Colors.black12,
          elevation: 0,
          type: MaterialType.card,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(4)),
          ),
          child: Align(
            alignment: Alignment.topLeft,
            child: TextField(
              controller: controller,
              keyboardType: inputType,
              maxLines: maxLines,
              enabled: isEnabled,
              style: const TextStyle(color: Colors.black87),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.fromLTRB(8, height >= 48 ? 8 : 2, 8, 8),
                hintText: hint,
                hintStyle: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 16,
                    overflow: TextOverflow.visible),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
