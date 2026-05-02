import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CircularSocialButton extends StatelessWidget {
  final String icon;
  final VoidCallback onTap;

  const CircularSocialButton({
    super.key,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 46.w,
        height: 46.w,
        decoration: BoxDecoration(
          color: theme.cardColor,
          shape: BoxShape.circle,
          border: Border.all(color: theme.dividerColor),
        ),
        child: Center(
          child: SvgPicture.asset(
            icon,
            width: 24.w,
          ),
        ),
      ),
    );
  }
}
