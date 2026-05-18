import 'package:doctor_appointment/core/utils/app_images.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
            return Center(
              child: Image.asset(
                Assets.imagesLogo,
                width: 200.w,
                fit: BoxFit.contain,
              ),
            );
          },
        ),
      ),
    );
  }
}
