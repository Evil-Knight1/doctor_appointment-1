import 'package:doctor_appointment/core/utils/app_colors.dart';
import 'package:doctor_appointment/core/utils/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ConsultationFeesWidget extends StatelessWidget {
  const ConsultationFeesWidget({super.key});

  static const List<Map<String, dynamic>> _fees = [
    {'label': 'Online Call', 'amount': '\$10', 'icon': Icons.call_outlined},
    {'label': 'Home Visit', 'amount': '\$20', 'icon': Icons.home_outlined},
    {'label': 'Video Call', 'amount': '\$30', 'icon': Icons.videocam_outlined},
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(_fees.length, (i) {
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: i < 2 ? 10.w : 0),
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                Icon(
                  _fees[i]['icon'] as IconData,
                  color: AppColors.primary,
                  size: 20.sp,
                ),
                SizedBox(height: 4.h),
                Text(
                  _fees[i]['amount'] as String,
                  style: AppStyles.styleSemiBold22.copyWith(
                    fontSize: 14.sp,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  _fees[i]['label'] as String,
                  style: AppStyles.styleRegular12.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 10.sp,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
