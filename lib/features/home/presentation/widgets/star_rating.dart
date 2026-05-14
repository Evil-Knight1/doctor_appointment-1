import 'package:doctor_appointment/core/theme/app_theme_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:doctor_appointment/core/utils/app_styles.dart';

class StarRating extends StatelessWidget {
  const StarRating({
    super.key,
    required this.rating,
    required this.reviewCount,
    this.iconSize = 12,
  });

  final double rating;
  final int reviewCount;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star_rounded,
            size: iconSize.sp, color: context.customColors.rating),
        SizedBox(width: 2.w),
        Text(
          rating.toStringAsFixed(1),
          style: context.bodySmall.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
            fontSize: iconSize.sp,
          ),
        ),
        SizedBox(width: 2.w),
        Text(
          '(${_formatCount(reviewCount)} reviews)',
          style: context.bodySmall.copyWith(
            fontSize: (iconSize - 1).sp,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  String _formatCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }
    return count.toString();
  }
}
