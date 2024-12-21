import 'package:flutter/material.dart';
import 'package:pos_admin/res/app_colors.dart';
import 'package:pos_admin/utills/app_utils.dart';
import 'package:provider/provider.dart';
import '../../../widgets/app_custom_text.dart';
import 'date_filter.dart';

class DatePickerWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final dateProvider = Provider.of<DateFilterProvider>(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CustomText(
          text:
              AppUtils.formateSimpleDate(dateTime:dateProvider.selectedDate.toString()),
          color: AppColors.white,size: 16,
          // style: TextStyle(fontSize: 16),
        ),
        IconButton(
          icon: Icon(
            Icons.calendar_today,
            color: AppColors.white,
          ),
          onPressed: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: dateProvider.selectedDate,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (pickedDate != null && pickedDate != dateProvider.selectedDate) {
              dateProvider.updateDate(pickedDate);
            }
          },
        ),
      ],
    );
  }
}
