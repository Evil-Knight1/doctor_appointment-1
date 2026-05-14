import 'package:doctor_appointment/core/utils/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DoctorStatsWidget extends StatelessWidget {
  final double rating;
  final int reviewCount;
  final int yearsOfExperience;

  const DoctorStatsWidget({
    super.key,
    required this.rating,
    required this.reviewCount,
    required this.yearsOfExperience,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem(context, reviewCount.toString(), 'Reviews', Icons.reviews_outlined),
          _divider(context),
          _statItem(context, '$yearsOfExperience Yrs', 'Experience', Icons.workspace_premium_outlined),
          _divider(context),
          _statItem(context, rating.toStringAsFixed(1), 'Ratings', Icons.star_outline_rounded),
        ],
      ),
    );
  }

  Widget _statItem(BuildContext context, String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: 22.sp),
        SizedBox(height: 4.h),
        Text(value, style: context.styleSemiBold22.copyWith(fontSize: 14.sp)),
        Text(
          label,
          style: context.styleRegular12.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _divider(BuildContext context) => Container(
        width: 1,
        height: 50.h,
        color: Theme.of(context).colorScheme.outlineVariant,
      );
}
