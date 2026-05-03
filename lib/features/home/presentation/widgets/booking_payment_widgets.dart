import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:doctor_appointment/core/utils/app_dimensions.dart';
import 'package:doctor_appointment/core/utils/app_colors.dart';
import 'package:doctor_appointment/core/utils/app_styles.dart';

class PaymentOptionGroup extends StatelessWidget {
  const PaymentOptionGroup({
    super.key,
    required this.label,
    required this.selected,
    required this.cards,
    required this.onSelect,
  });
  final String label;
  final String selected;
  final List<(String, IconData, Color)> cards;
  final ValueChanged<String> onSelect;

  bool get _isCreditSelected => cards.any((c) => c.$1 == selected);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RadioRow(
          label: label,
          selected: _isCreditSelected,
          onTap: () => onSelect(cards.first.$1),
        ),
        if (_isCreditSelected)
          Container(
            margin: EdgeInsets.only(
              left: AppSpacing.lg,
              bottom: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              boxShadow: [
                BoxShadow(
                  color: AppColors.cardShadow.withValues(alpha: 0.07),
                  blurRadius: 10.r,
                ),
              ],
            ),
            child: Column(
              children: cards
                  .map(
                    (c) => CardTile(
                      name: c.$1,
                      icon: c.$2,
                      color: c.$3,
                      selected: selected == c.$1,
                      onTap: () => onSelect(c.$1),
                    ),
                  )
                  .toList(),
            ),
          ),
      ],
    );
  }
}

class RadioRow extends StatelessWidget {
  const RadioRow({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          children: [
            Container(
              width: 20.w,
              height: 20.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? AppColors.primary : AppColors.textHint,
                  width: 2.w,
                ),
              ),
              child: selected
                  ? Center(
                      child: Container(
                        width: 10.w,
                        height: 10.h,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  : null,
            ),
            SizedBox(width: AppSpacing.md),
            Text(label, style: AppTextStyles.headingSmall),
          ],
        ),
      ),
    );
  }
}

class CardTile extends StatelessWidget {
  const CardTile({
    super.key,
    required this.name,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });
  final String name;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryLight : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22.sp),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                name,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            if (selected)
              Icon(
                Icons.check_circle_rounded,
                color: AppColors.primary,
                size: 18.sp,
              ),
          ],
        ),
      ),
    );
  }
}

class OtherMethodTile extends StatelessWidget {
  const OtherMethodTile({
    super.key,
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: AppSpacing.sm),
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryLight : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: selected
              ? Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1.w)
              : null,
          boxShadow: [
            BoxShadow(
              color: AppColors.cardShadow.withValues(alpha: 0.07),
              blurRadius: 8.r,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 20.w,
              height: 20.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? AppColors.primary : AppColors.textHint,
                  width: 2.w,
                ),
              ),
              child: selected
                  ? Center(
                      child: Container(
                        width: 10.w,
                        height: 10.h,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  : null,
            ),
            SizedBox(width: AppSpacing.md),
            Icon(
              icon,
              size: 22.sp,
              color: selected ? AppColors.primary : AppColors.textSecondary,
            ),
            SizedBox(width: AppSpacing.sm),
            Text(label, style: AppTextStyles.headingSmall),
          ],
        ),
      ),
    );
  }
}

class ContinueBar extends StatelessWidget {
  const ContinueBar({super.key, required this.onContinue, this.label = 'Continue'});
  final VoidCallback onContinue;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.xl,
      ),
      child: SizedBox(
        height: 52.h,
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onContinue,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            elevation: 0,
          ),
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 15.sp,
            ),
          ),
        ),
      ),
    );
  }
}
