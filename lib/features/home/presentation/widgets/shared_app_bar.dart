import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:doctor_appointment/core/utils/app_colors.dart';
import 'package:doctor_appointment/core/utils/app_styles.dart';

class SharedAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SharedAppBar({
    super.key,
    required this.title,
    this.actions,
    this.onBack,
    this.centerTitle = true,
  });

  final String title;
  final List<Widget>? actions;
  final VoidCallback? onBack;
  final bool centerTitle;

  @override
  Size get preferredSize => Size.fromHeight(72.h);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: centerTitle,
      leading: _BackButton(onBack: onBack),
      title: Text(title, style: AppTextStyles.headingLarge),
      actions: actions,
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({this.onBack});
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onBack ?? () => Navigator.of(context).pop(),
      child: Container(
        margin: EdgeInsets.only(left: 16.w),
        width: 40.w,
        height: 40.w,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.cardShadow.withValues(alpha: 0.08),
              blurRadius: 8.r,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        child: Icon(Icons.arrow_back_ios_new_rounded,
            size: 14.sp, color: AppColors.textPrimary),
      ),
    );
  }
}