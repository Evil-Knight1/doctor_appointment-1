import 'package:doctor_appointment/core/utils/app_colors.dart';
import 'package:doctor_appointment/core/utils/app_styles.dart';
import 'package:doctor_appointment/core/utils/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:doctor_appointment/features/on_boarding_view/presentation/widgets/custom_button.dart';

class DoctorPendingApprovalView extends StatelessWidget {
  const DoctorPendingApprovalView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.admin_panel_settings_rounded,
                size: 80.sp,
                color: AppColors.primary,
              ),
              SizedBox(height: 24.h),
              Text(
                'Application Received',
                textAlign: TextAlign.center,
                style: AppStyles.styleSemiBold24,
              ),
              SizedBox(height: 16.h),
              Text(
                'Your registration as a Doctor has been successfully submitted. Our administration team is reviewing your details to verify your medical credentials. You will receive an email once approved.',
                style: AppStyles.styleRegular14.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40.h),
              CustomButton(
                text: 'Back to Login',
                onPressed: () {
                  context.go(AppRouter.kLoginView);
                },
                width: double.infinity,
                height: 50.h,
                circleSize: 12.r,
                textStyle: AppStyles.styleSemiBold16,
                buttonColor: AppColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
