import 'package:doctor_appointment/core/utils/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';

class SplashTablet extends StatelessWidget {
  const SplashTablet({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 300.w,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 100.w,
                child: SvgPicture.asset(
                  'assets/images/docdoc_logo.svg',
                  fit: BoxFit.contain,
                ),
              ),
              Text(
                'MedLink',
                style: context.styleBold32.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 40.h),
        SpinKitFadingCircle(
          color: Theme.of(context).colorScheme.primary,
          size: 55,
        ),
      ],
    );
  }
}
