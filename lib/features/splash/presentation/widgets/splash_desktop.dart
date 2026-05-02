import 'package:doctor_appointment/core/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
              children: [
                Expanded(
                  child: SvgPicture.asset(
                    'assets/images/docdoc_logo.svg',
                    width: 350,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 40),
                const SpinKitFadingCircle(color: AppColors.primary, size: 60),
              ],
            );
          },
        ),
      ),
    );
  }
}
