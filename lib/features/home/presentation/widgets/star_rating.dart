import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:doctor_appointment/core/utils/app_styles.dart';
import 'package:doctor_appointment/core/utils/app_colors.dart';

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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star_rounded, size: iconSize.sp, color: AppColors.star),
        SizedBox(width: 2.w),
        Text(
          rating.toStringAsFixed(1),
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: iconSize.sp,
          ),
        ),
        SizedBox(width: 2.w),
        Text(
          '(${_formatCount(reviewCount)} reviews)',
          style: AppTextStyles.bodySmall.copyWith(fontSize: (iconSize - 1).sp),
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
