import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:doctor_appointment/core/utils/app_dimensions.dart';
import 'package:doctor_appointment/features/home/data/models/home_model.dart';
import 'package:doctor_appointment/core/utils/app_colors.dart';
import 'package:doctor_appointment/core/utils/app_styles.dart';

class ConfirmedBadge extends StatelessWidget {
  const ConfirmedBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80.w,
          height: 80.h,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.secondary.withValues(alpha: 0.15),
          ),
          child: Icon(
            Icons.check_circle_rounded,
            color: AppColors.secondary,
            size: 60.sp,
          ),
        ),
        SizedBox(height: AppSpacing.lg),
        Text('Booking Confirmed', style: AppTextStyles.displayMedium),
      ],
    );
  }
}

class ConfirmedInfoSection extends StatelessWidget {
  const ConfirmedInfoSection({super.key, required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow.withValues(alpha: 0.08),
            blurRadius: 14.r,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.headingMedium),
          SizedBox(height: AppSpacing.md),
          ...children,
        ],
      ),
    );
  }
}

class BookingInfoRow extends StatelessWidget {
  const BookingInfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.trailing,
  });
  final IconData icon;
  final String label;
  final String value;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 36.w,
          height: 36.h,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Icon(icon, size: 18.sp, color: AppColors.primary),
        ),
        SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.bodySmall),
              Text(value, style: AppTextStyles.headingSmall),
            ],
          ),
        ),
        ?trailing,
      ],
    );
  }
}

class DoctorInfoRow extends StatelessWidget {
  const DoctorInfoRow({super.key, required this.doctor});
  final DoctorModel doctor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 52.w,
          height: 52.h,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Icon(
            Icons.person_rounded,
            color: AppColors.primary,
            size: 30.sp,
          ),
        ),
        SizedBox(width: AppSpacing.md),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(doctor.name, style: AppTextStyles.headingSmall),
            Text(
              '${doctor.speciality} | ${doctor.hospital}',
              style: AppTextStyles.bodySmall,
            ),
            Row(
              children: [
                Icon(Icons.star_rounded, size: 12.sp, color: AppColors.star),
                SizedBox(width: 2.w),
                Text(
                  '${doctor.rating} (${doctor.reviewCount} reviews)',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class BookingConfirmedActions extends StatelessWidget {
  const BookingConfirmedActions({
    super.key,
    required this.onDone,
    required this.onReview,
  });
  final VoidCallback onDone;
  final VoidCallback onReview;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.xl,
      ),
      child: Column(
        children: [
          SizedBox(
            height: 52.h,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onDone,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                elevation: 0,
              ),
              child: Text(
                'Done',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 15.sp,
                ),
              ),
            ),
          ),
          SizedBox(height: AppSpacing.md),
          GestureDetector(
            onTap: onReview,
            child: Text(
              'Leave a Review',
              style: AppTextStyles.labelLarge.copyWith(fontSize: 14.sp),
            ),
          ),
        ],
      ),
    );
  }
}
