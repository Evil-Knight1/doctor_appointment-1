import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:doctor_appointment/core/utils/app_dimensions.dart';
import 'package:doctor_appointment/features/doctors/domain/entities/doctor.dart';
import 'package:doctor_appointment/core/utils/app_styles.dart';
import 'package:doctor_appointment/core/theme/app_theme_extension.dart';

class ConfirmedBadge extends StatelessWidget {
  const ConfirmedBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Column(
      children: [
        Container(
          width: 80.w,
          height: 80.h,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colorScheme.secondary.withValues(alpha: 0.15),
          ),
          child: Icon(
            Icons.check_circle_rounded,
            color: colorScheme.secondary,
            size: 60.sp,
          ),
        ),
        SizedBox(height: AppSpacing.lg),
        Text('Booking Confirmed', style: context.displayMedium),
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
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.08),
            blurRadius: 14.r,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: context.headingMedium),
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
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 36.w,
          height: 36.h,
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Icon(icon, size: 18.sp, color: colorScheme.primary),
        ),
        SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label, 
                style: context.bodySmall.copyWith(color: colorScheme.onSurfaceVariant),
              ),
              Text(
                value, 
                style: context.headingSmall.copyWith(color: colorScheme.onSurface),
              ),
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
  final Doctor doctor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final customColors = context.customColors;

    return Row(
      children: [
        Container(
          width: 52.w,
          height: 52.h,
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Icon(
            Icons.person_rounded,
            color: colorScheme.primary,
            size: 30.sp,
          ),
        ),
        SizedBox(width: AppSpacing.md),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              doctor.fullName, 
              style: context.headingSmall.copyWith(color: colorScheme.onSurface),
            ),
            Text(
              '${doctor.specialization.name} | ${doctor.hospital ?? 'Clinic'}',
              style: context.bodySmall.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            Row(
              children: [
                Icon(
                  Icons.star_rounded, 
                  size: 12.sp, 
                  color: customColors.rating ?? Colors.amber,
                ),
                SizedBox(width: 2.w),
                Text(
                  '${doctor.averageRating?.toStringAsFixed(1) ?? '0.0'} (${doctor.totalReviews} reviews)',
                  style: context.bodySmall.copyWith(color: colorScheme.onSurfaceVariant),
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
    final colorScheme = Theme.of(context).colorScheme;

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
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                elevation: 0,
              ),
              child: Text(
                'Done',
                style: TextStyle(
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
              style: context.labelLarge.copyWith(
                fontSize: 14.sp,
                color: colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
