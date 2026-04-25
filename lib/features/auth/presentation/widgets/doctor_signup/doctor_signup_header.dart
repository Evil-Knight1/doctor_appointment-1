import 'package:doctor_appointment/core/utils/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class DoctorSignUpHeader extends StatelessWidget {
  const DoctorSignUpHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20.h),
        _BackButton(onTap: () => context.pop()),
        SizedBox(height: 20.h),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Doctor\nRegistration',
                    style: AppStyles.styleSemiBold24,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Join our network of healthcare professionals.',
                    style: AppStyles.styleRegular14.copyWith(
                      color: const Color(0xFF949D9E),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 12.w),
            Container(
              width: 56.w,
              height: 56.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xff236DEC),
                    const Color(0xff236DEC).withValues(alpha: 0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Icon(
                Icons.medical_services_rounded,
                color: Colors.white,
                size: 28.sp,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40.w,
        height: 40.h,
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 16.sp,
          color: const Color(0xff1E252D),
        ),
      ),
    );
  }
}
