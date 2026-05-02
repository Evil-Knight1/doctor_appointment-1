import 'package:doctor_appointment/core/utils/app_colors.dart';
import 'package:doctor_appointment/core/utils/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ConsultationTypeWidget extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelected;

  const ConsultationTypeWidget({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  static const List<String> types = ['Online', 'Home visit', 'Hospital'];
  static const Map<String, IconData> icons = {
    'Online': Icons.laptop_mac_outlined,
    'Home visit': Icons.home_outlined,
    'Hospital': Icons.local_hospital_outlined,
  };

  @override
  Widget build(BuildContext context) {
    return Row(
      children: types.map((type) {
        final isSelected = selected == type;
        return GestureDetector(
          onTap: () => onSelected(type),
          child: Container(
            margin: EdgeInsets.only(right: 10.w),
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icons[type],
                  size: 14.sp,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
                SizedBox(width: 4.w),
                Text(
                  type,
                  style: AppStyles.styleRegular12.copyWith(
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
