import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:doctor_appointment/core/utils/app_dimensions.dart';
import 'package:doctor_appointment/core/utils/routes.dart';
import 'package:doctor_appointment/core/utils/app_styles.dart';
import 'package:doctor_appointment/core/utils/app_colors.dart';

class _QuickAccessItem {
  const _QuickAccessItem({
    required this.label,
    required this.icon,
    required this.color,
    required this.bgColor,
  });

  final String label;
  final IconData icon;
  final Color color;
  final Color bgColor;
}

class QuickAccessGrid extends StatelessWidget {
  const QuickAccessGrid({super.key});

  static const List<_QuickAccessItem> _items = [
    _QuickAccessItem(
      label: 'Find\nNearby',
      icon: Icons.location_on_outlined,
      color: Color(0xFF2563EB),
      bgColor: Color(0xFFEFF6FF),
    ),
    _QuickAccessItem(
      label: 'Video\nCall',
      icon: Icons.video_call_outlined,
      color: Color(0xFF059669),
      bgColor: Color(0xFFECFDF5),
    ),
    _QuickAccessItem(
      label: 'Phone\nCall',
      icon: Icons.phone_outlined,
      color: Color(0xFFD97706),
      bgColor: Color(0xFFFFFBEB),
    ),
    _QuickAccessItem(
      label: 'My\nRecords',
      icon: Icons.description_outlined,
      color: Color(0xFF7C3AED),
      bgColor: Color(0xFFF5F3FF),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: List.generate(
          _items.length,
          (index) => Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                left: index == 0 ? 0 : (AppSpacing.sm / 2),
                right: index == _items.length - 1 ? 0 : (AppSpacing.sm / 2),
              ),
              child: _QuickAccessCard(item: _items[index]),
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickAccessCard extends StatelessWidget {
  const _QuickAccessCard({required this.item});

  final _QuickAccessItem item;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (item.label == 'Find\nNearby') {
          context.pushNamed(Routes.findNearbyView);
        }
      },
      child: Container(
        height: 80.h,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: [
            BoxShadow(
              color: AppColors.cardShadow.withValues(alpha: 0.08),
              blurRadius: 10.r,
              offset: Offset(0, 3.h),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 36.w,
              height: 36.h,
              decoration: BoxDecoration(
                color: item.bgColor,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(item.icon, size: 18.sp, color: item.color),
            ),
            SizedBox(height: 4.h),
            Text(
              item.label,
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 10.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
