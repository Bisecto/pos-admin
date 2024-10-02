import 'package:flutter/material.dart';

import '../../res/app_colors.dart';
import '../../utills/app_utils.dart';
import 'app_custom_text.dart';
class DropDown extends StatefulWidget {
  final String selectedValue;
  final String label;
  final String hint;
  final double width;
  final double textSize;
  final double height;
  final String? initialValue;
  final List<String> items;
  final Color? color;
  final Color? labelColor;
  final Color? borderColor;
  final Color? dropIconColor;
  final bool showLabel;
  final bool showIcon;
  final bool showBorder;
  final double borderRadius;
  final ValueChanged<String> onChanged;

  const DropDown({
    Key? key,
    required this.selectedValue,
    this.label = '',
    this.hint = '',
    this.width = double.infinity,
    this.height = 44,
    required this.items,
    this.initialValue,
    this.labelColor,
    this.showLabel = true,
    this.showIcon = false,
    this.showBorder = true,
    this.borderColor,
    this.color,
    this.borderRadius = 4,
    this.dropIconColor,
    this.textSize = 12,
    required this.onChanged,
  }) : super(key: key);

  @override
  _DropDownState createState() => _DropDownState();
}

class _DropDownState extends State<DropDown> {
  late String _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.initialValue ?? widget.selectedValue;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showLabel)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: CustomText(
              text: widget.label,
              size: widget.textSize,
              color: widget.labelColor ?? widget.color ?? AppColors.textColor2,
            ),
          ),
        Material(
          elevation: 0,
          type: MaterialType.card,
          color: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(widget.borderRadius),
            ),
          ),
          child: Container(
            width: widget.width,
            height: widget.height,
            padding: const EdgeInsets.only(left: 0),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.all(Radius.circular(widget.borderRadius)),
              border: widget.showBorder
                  ? Border.all(color: widget.borderColor ?? Colors.black12)
                  : null,
            ),
            child: DropdownButton<String>(
              iconEnabledColor: widget.dropIconColor ?? Colors.black54,
              icon: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Icon(
                  Icons.expand_more,
                  size: 22,
                  color: widget.borderColor,
                ),
              ),
              isExpanded: true,
              iconSize: 24,
              alignment: Alignment.bottomCenter,
              underline: Container(color: Colors.transparent),
              value: widget.items.contains(_selectedValue)
                  ? _selectedValue
                  : null,
              onChanged: (newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedValue = newValue;
                  });
                  widget.onChanged(newValue);
                }
              },
              hint: Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    widget.hint,
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ),
              ),
              items: widget.items.map((data) {
                return DropdownMenuItem<String>(
                  value: data,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Text(
                      data,
                      style: TextStyle(fontSize: widget.textSize,color: AppColors.white),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
