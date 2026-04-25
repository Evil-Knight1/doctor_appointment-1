import 'package:doctor_appointment/core/utils/app_colors.dart';
import 'package:doctor_appointment/core/utils/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AvailableSlotsWidget extends StatelessWidget {
  final String selectedSlot;
  final ValueChanged<String> onSlotSelected;

  const AvailableSlotsWidget({
    super.key,
    required this.selectedSlot,
    required this.onSlotSelected,
  });

  static const List<String> slots = ['Morning', 'Afternoon', 'Night'];
  static const Map<String, IconData> icons = {
    'Morning': Icons.wb_sunny_outlined,
    'Afternoon': Icons.wb_cloudy_outlined,
    'Night': Icons.nightlight_outlined,
  };

  @override
  Widget build(BuildContext context) {
    return Row(
      children: slots.map((slot) {
        final isSelected = selectedSlot == slot;
        return GestureDetector(
          onTap: () => onSlotSelected(slot),
          child: Container(
            margin: EdgeInsets.only(right: 10.w),
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : AppColors.bg,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icons[slot],
                  size: 14.sp,
                  color: isSelected ? Colors.white : AppColors.star,
                ),
                SizedBox(width: 4.w),
                Text(
                  slot,
                  style: AppStyles.styleMedium12.copyWith(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
