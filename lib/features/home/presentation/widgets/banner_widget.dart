import 'package:doctor_appointment/core/utils/app_colors.dart';
import 'package:doctor_appointment/core/utils/app_images.dart';
import 'package:doctor_appointment/core/utils/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BannerWidget extends StatelessWidget {
  const BannerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150.h,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1D4ED8), AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Stack(
        children: [
          // Decorative circle
          Positioned(
            right: -20.w,
            top: -20.h,
            child: Container(
              width: 130.w,
              height: 130.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            right: 20.w,
            bottom: -30.h,
            child: Container(
              width: 90.w,
              height: 90.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          // Doctor image
          Positioned(
            right: 10.w,
            bottom: 0,
            child: Image.asset(
              Assets.imagesDoctorsGroup,
              height: 140.h,
              errorBuilder: (_, _, _) => SizedBox(width: 120.w),
            ),
          ),
          // Text content - constrained to avoid overflow
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            right: 130.w,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Medigo',
                    style: AppStyles.styleSemiBold24.copyWith(
                      color: Colors.white,
                      fontSize: 22.sp,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Your doctor, one\ntap away.',
                    style: AppStyles.styleRegular14.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 12.sp,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      'Book Now',
                      style: AppStyles.styleMedium14.copyWith(
                        color: AppColors.primary,
                        fontSize: 11.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
