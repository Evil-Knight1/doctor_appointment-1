import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:doctor_appointment/core/utils/routes.dart';
import 'package:doctor_appointment/core/utils/app_styles.dart';
import 'package:doctor_appointment/core/utils/app_colors.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight.h);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 20.w,
      title: const _LocationRow(),
      actions: [const _NotificationButton(), SizedBox(width: 16.w)],
    );
  }
}

class _LocationRow extends StatelessWidget {
  const _LocationRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.location_on_rounded,
          size: 16.sp,
          color: AppColors.primary,
        ),
        SizedBox(width: 4.w),
        Text(
          'Cairo, Egypt',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(width: 2.w),
        Icon(
          Icons.keyboard_arrow_down_rounded,
          size: 16.sp,
          color: AppColors.textSecondary,
        ),
      ],
    );
  }
}

class _NotificationButton extends StatelessWidget {
  const _NotificationButton();

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
      GestureDetector(
        onTap: () => context.pushNamed(Routes.notificationView),
        child: Container(
          width: 40.w,
          height: 40.h,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.cardShadow.withValues(alpha: 0.08),
                blurRadius: 8.r,
                offset: Offset(0, 2.h),
              ),
            ],
          ),
          child: Icon(
            Icons.notifications_outlined,
            size: 20.sp,
            color: AppColors.textPrimary,
          ),
        ),
      ),
        Positioned(
          top: 8.h,
          right: 8.w,
          child: Container(
            width: 8.w,
            height: 8.h,
            decoration: const BoxDecoration(
              color: Color(0xFFEF4444),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }
}
