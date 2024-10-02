import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  final double buttonHeight;
  final double buttonWidth;
  final BoxDecoration buttonBoxDecoration;
  final Widget buttonChild;
  final VoidCallback buttonCallback;
  const AppButton({
    super.key,
    required this.buttonBoxDecoration,
    required this.buttonHeight,
    required this.buttonChild,
    required this.buttonWidth,
    required this.buttonCallback,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: buttonCallback,
      child: Container(
        height: buttonHeight,
        width: buttonWidth,
        decoration: buttonBoxDecoration,
        child: Center(
          child: buttonChild,
        ),
      ),
    );
  }
}
