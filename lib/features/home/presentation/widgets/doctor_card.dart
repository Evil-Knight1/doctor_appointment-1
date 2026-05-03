import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:doctor_appointment/core/utils/routes.dart';
import 'package:doctor_appointment/core/utils/app_dimensions.dart';
import 'package:doctor_appointment/features/home/data/models/home_model.dart';
import 'package:doctor_appointment/core/utils/app_styles.dart';
import 'package:doctor_appointment/core/utils/app_colors.dart';
import 'star_rating.dart';

class DoctorCard extends StatelessWidget {
  const DoctorCard({super.key, required this.doctor});

  final DoctorModel doctor;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow.withValues(alpha: 0.09),
            blurRadius: 16.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: InkWell(
          onTap: () => context.pushNamed(
            Routes.doctorDetailsView,
            extra: doctor,
          ),
          borderRadius: BorderRadius.circular(AppRadius.xl),
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                _DoctorAvatar(doctor: doctor),
                SizedBox(width: AppSpacing.md),
                Expanded(child: _DoctorInfo(doctor: doctor)),
                const _BookmarkButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DoctorAvatar extends StatelessWidget {
  const _DoctorAvatar({required this.doctor});

  final DoctorModel doctor;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 64.w,
          height: 64.h,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Icon(
            Icons.person_rounded,
            size: 36.sp,
            color: AppColors.primary,
          ),
        ),
        if (doctor.isAvailable)
          Positioned(
            bottom: 2.h,
            right: 2.w,
            child: Container(
              width: 12.w,
              height: 12.h,
              decoration: BoxDecoration(
                color: AppColors.secondary,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.surface, width: 2.w),
              ),
            ),
          ),
      ],
    );
  }
}

class _DoctorInfo extends StatelessWidget {
  const _DoctorInfo({required this.doctor});

  final DoctorModel doctor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          doctor.name,
          style: AppTextStyles.headingMedium,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 2.h),
        Text(
          '${doctor.speciality} | ${doctor.hospital}',
          style: AppTextStyles.bodySmall,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 6.h),
        StarRating(rating: doctor.rating, reviewCount: doctor.reviewCount),
      ],
    );
  }
}

class _BookmarkButton extends StatelessWidget {
  const _BookmarkButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36.w,
      height: 36.h,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Icon(
        Icons.bookmark_outline_rounded,
        size: 18.sp,
        color: AppColors.textSecondary,
      ),
    );
  }
}
