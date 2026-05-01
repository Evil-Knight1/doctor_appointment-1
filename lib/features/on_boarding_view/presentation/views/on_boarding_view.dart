import 'package:doctor_appointment/core/utils/app_colors.dart';
import 'package:doctor_appointment/core/utils/app_styles.dart';
import 'package:doctor_appointment/core/utils/go_router.dart';
import 'package:doctor_appointment/features/on_boarding_view/presentation/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:doctor_appointment/core/services/shared_preferences_helper.dart';

class OnBoardingView extends StatelessWidget {
  const OnBoardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 30.h),
              // Logo
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/images/docdoc_logo.svg',
                    width: 140.w,
                  ),
                ],
              ),
              SizedBox(height: 30.h),
              // Doctor Image with Gradient & Title Overlay
              Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset(
                    'assets/images/onboarding_doctors.png',
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 250.h,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Theme.of(context).scaffoldBackgroundColor,
                            Theme.of(context).scaffoldBackgroundColor.withAlpha(0),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 10.h,
                    child: Text(
                      'Best Doctor\nAppointment App',
                      textAlign: TextAlign.center,
                      style: AppStyles.styleBold32,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 18.h),
              // Description
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 30.w),
                child: Text(
                  'Manage and schedule all of your medical appointments easily with Docdoc to get a new experience.',
                  textAlign: TextAlign.center,
                  style: AppStyles.styleRegular12,
                ),
              ),
              SizedBox(height: 35.h),
              // Get Started Button
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 30.w),
                child: CustomButton(
                  height: 52.h,
                  width: double.infinity,
                  text: 'Get Started',
                  onPressed: () async {
                    await SharedPreferencesHelper.saveHasSeenOnboarding(true);
                    if (context.mounted) context.go(AppRouter.kUserSelectionView);
                  },
                  buttonColor: AppColors.primary,
                  textStyle: AppStyles.styleSemiBold16,
                  circleSize: 16.r,
                ),
              ),
              SizedBox(height: 30.h),
            ],
          ),
        ),
      ),
    );
  }
}
