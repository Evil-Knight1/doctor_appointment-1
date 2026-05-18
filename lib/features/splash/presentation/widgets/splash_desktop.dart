import 'package:doctor_appointment/core/utils/app_images.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:doctor_appointment/core/theme/app_theme_extension.dart';

class SplashDesktop extends StatelessWidget {
  const SplashDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 700, // مهم جدًا
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Image.asset(
                  Assets.imagesLogo,
                  width: 150.w,
                  fit: BoxFit.contain,
                ),
                SizedBox(height: 12.h),
                Text(
                  'MedLink',
                  style: context.styleBold32.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
