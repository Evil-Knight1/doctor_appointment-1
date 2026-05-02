import 'package:doctor_appointment/core/utils/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

class CustomSocialButton extends StatelessWidget {
  const CustomSocialButton({
    super.key,
    required this.label,
    required this.onTap,
    this.iconPath,
  });

  final String label;
  final VoidCallback onTap;
  final String? iconPath; // ✅ String

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: theme.dividerColor, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              // ✅ مباشرة بدون Container
              iconPath ?? '',
              width: 24.w,
              height: 24.h,
            ),
            SizedBox(width: 12.w),
            Text(
              label,
              style: AppStyles.styleMedium14.copyWith(
                color: theme.textTheme.headlineLarge?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
