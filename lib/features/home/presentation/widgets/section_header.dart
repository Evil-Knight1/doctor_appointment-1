import 'package:flutter/material.dart';
import 'package:doctor_appointment/core/utils/app_dimensions.dart';
import 'package:doctor_appointment/core/utils/app_styles.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.onSeeAllTap,
    this.showSeeAll = true,
  });

  final String title;
  final VoidCallback? onSeeAllTap;
  final bool showSeeAll;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTextStyles.sectionTitle),
          if (showSeeAll)
            GestureDetector(
              onTap: onSeeAllTap,
              child: Text('See All', style: AppTextStyles.labelLarge),
            ),
        ],
      ),
    );
  }
}
