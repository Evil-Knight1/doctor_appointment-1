import 'package:doctor_appointment/core/utils/app_colors.dart';
import 'package:doctor_appointment/core/utils/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class DatePickerWidget extends StatelessWidget {
  final DateTime selectedDate;
  final List<DateTime> weekDays;
  final ValueChanged<DateTime> onDateSelected;

  const DatePickerWidget({
    super.key,
    required this.selectedDate,
    required this.weekDays,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Month selector
        Row(
          children: [
            Text(
              DateFormat('MMMM, yyyy').format(selectedDate),
              style: AppStyles.styleMedium14.copyWith(fontSize: 15.sp),
            ),
            SizedBox(width: 4.w),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.textSecondary,
              size: 18.sp,
            ),
          ],
        ),
        SizedBox(height: 16.h),
        // Days row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: weekDays.map((date) {
            final isSelected = date.day == selectedDate.day;
            return GestureDetector(
              onTap: () => onDateSelected(date),
              child: Container(
                width: 60.w,
                height: 72.h,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${date.day}',
                      style: AppStyles.styleSemiBold22.copyWith(
                        fontSize: 20.sp,
                        color: isSelected
                            ? Colors.white
                            : AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      DateFormat('EEE').format(date).toUpperCase(),
                      style: AppStyles.styleRegular12.copyWith(
                        fontSize: 10.sp,
                        color: isSelected
                            ? Colors.white70
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
