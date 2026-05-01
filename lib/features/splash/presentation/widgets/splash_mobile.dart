import 'package:doctor_appointment/core/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';

class SplashMobile extends StatelessWidget {
  const SplashMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const Spacer(flex: 3),
          Expanded(
            flex: 4,
            child: Center(
              child: SizedBox(
                width: 250.w,
                child: SvgPicture.asset('assets/images/docdoc_logo.svg'),
              ),
            ),
          ),
          const Expanded(
            flex: 2,
            child: Center(
              child: SpinKitFadingCircle(color: AppColors.primary, size: 50),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
