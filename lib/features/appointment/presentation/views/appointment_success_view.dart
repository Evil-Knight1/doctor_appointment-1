import 'package:doctor_appointment/core/theme/app_theme_extension.dart';
import 'package:doctor_appointment/core/utils/app_styles.dart';
import 'package:doctor_appointment/core/utils/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class AppointmentSuccessView extends StatelessWidget {
  const AppointmentSuccessView({super.key});

  @override
  Widget build(BuildContext context) {
    final customColors = context.customColors;
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Success icon
              Container(
                width: 100.w,
                height: 100.w,
                decoration: BoxDecoration(
                  color: customColors.success?.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle_rounded,
                  color: customColors.success,
                  size: 60.sp,
                ),
              ),
              SizedBox(height: 32.h),
              Text(
                'Congratulations !',
                style: AppStyles.styleSemiBold22(context).copyWith(
                  fontSize: 22.sp,
                  color: colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 12.h),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: AppStyles.styleRegular14(context).copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.6,
                  ),
                  children: [
                    const TextSpan(
                      text: 'Laith mahdi, your appointment with\n',
                    ),
                    TextSpan(
                      text: 'Dr. Ayesha Rahman',
                      style: AppStyles.styleMedium14(context).copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const TextSpan(text: ' has been booked.'),
                  ],
                ),
              ),
              SizedBox(height: 32.h),
              // Date & Time
              _infoRow(context, Icons.calendar_today_outlined, '10 Nov, 2023'),
              SizedBox(height: 12.h),
              _infoRow(context, Icons.access_time_rounded, '10:00'),
              const Spacer(),
              // Button
              ElevatedButton(
                onPressed: () => context.go(AppRouter.kRoot),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  minimumSize: Size(double.infinity, 52.h),
                  elevation: 0,
                ),
                child: Text(
                  'See Appointment',
                  style: AppStyles.styleSemiBold16(context),
                ),
              ),
              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(BuildContext context, IconData icon, String text) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: colorScheme.primary, size: 18.sp),
        SizedBox(width: 8.w),
        Text(
          text,
          style: AppStyles.styleMedium14(context).copyWith(color: colorScheme.onSurface),
        ),
      ],
    );
  }
}

