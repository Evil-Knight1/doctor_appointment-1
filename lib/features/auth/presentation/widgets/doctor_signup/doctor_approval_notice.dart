import 'package:doctor_appointment/core/utils/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DoctorApprovalNotice extends StatelessWidget {
  const DoctorApprovalNotice({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: const Color(0xFFFDBA74).withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32.w,
            height: 32.h,
            decoration: BoxDecoration(
              color: const Color(0xFFF97316).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              Icons.info_outline_rounded,
              color: const Color(0xFFF97316),
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
                    color: const Color(0xFF9A3412),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Your account will be reviewed by our admin team before activation. This usually takes 1-2 business days.',
                  style: AppStyles.styleRegular12.copyWith(
                    color: const Color(0xFFEA580C),
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
