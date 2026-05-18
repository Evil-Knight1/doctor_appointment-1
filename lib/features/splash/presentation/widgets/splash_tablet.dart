import 'package:doctor_appointment/core/utils/app_images.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:doctor_appointment/core/theme/app_theme_extension.dart';

class SplashTablet extends StatelessWidget {
  const SplashTablet({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(width: 100.w, child: Image.asset(Assets.imagesLogo)),
        SizedBox(height: 12.h),
        Text(
          'MedLink',
          style: context.styleBold32.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
