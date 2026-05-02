import 'package:doctor_appointment/core/utils/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DoctorApprovalNotice extends StatelessWidget {
  const DoctorApprovalNotice({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Use secondary color scheme for the warning/notice look
    // If secondary is not orange-ish, it will at least be harmonious with the theme
    final baseColor = theme.colorScheme.secondary;
    final containerColor = theme.colorScheme.secondaryContainer;
    final onContainerColor = theme.colorScheme.onSecondaryContainer;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: containerColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: baseColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32.w,
            height: 32.h,
            decoration: BoxDecoration(
              color: baseColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              Icons.info_outline_rounded,
              color: baseColor,
              size: 18.sp,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Verification Required',
                  style: AppStyles.styleMedium14.copyWith(
                    color: onContainerColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Your account will be reviewed by our admin team before activation. This usually takes 1-2 business days.',
                  style: AppStyles.styleRegular12.copyWith(
                    color: onContainerColor.withValues(alpha: 0.9),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
