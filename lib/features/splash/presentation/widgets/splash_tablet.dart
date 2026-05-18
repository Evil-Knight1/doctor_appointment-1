import 'package:doctor_appointment/core/utils/app_images.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SplashTablet extends StatelessWidget {
  const SplashTablet({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.asset(Assets.imagesLogo, width: 100.w, fit: BoxFit.contain),
    );
  }
}
