import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:doctor_appointment/core/utils/app_dimensions.dart';
import 'package:doctor_appointment/core/utils/routes.dart';
import 'package:doctor_appointment/core/utils/app_styles.dart';
import 'package:doctor_appointment/core/utils/app_colors.dart';

import 'package:doctor_appointment/l10n/app_localizations.dart';

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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final List<_QuickAccessItem> items = [
      _QuickAccessItem(
        label: l10n.findNearbyGrid,
        icon: Icons.location_on_outlined,
        color: const Color(0xFF2563EB),
        bgColor: const Color(0xFFEFF6FF),
      ),
      _QuickAccessItem(
        label: l10n.videoCall,
        icon: Icons.video_call_outlined,
        color: const Color(0xFF059669),
        bgColor: const Color(0xFFECFDF5),
      ),
      _QuickAccessItem(
        label: l10n.phoneCall,
        icon: Icons.phone_outlined,
        color: const Color(0xFFD97706),
        bgColor: const Color(0xFFFFFBEB),
      ),
      _QuickAccessItem(
        label: l10n.myRecords,
        icon: Icons.description_outlined,
        color: const Color(0xFF7C3AED),
        bgColor: const Color(0xFFF5F3FF),
      ),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: List.generate(
          items.length,
          (index) => Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                left: index == 0 ? 0 : (AppSpacing.sm / 2),
                right: index == items.length - 1 ? 0 : (AppSpacing.sm / 2),
              ),
              child: _QuickAccessCard(
                item: items[index],
                isNearby: index == 0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickAccessCard extends StatelessWidget {
  const _QuickAccessCard({required this.item, this.isNearby = false});

  final _QuickAccessItem item;
  final bool isNearby;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (isNearby) {
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
