import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:doctor_appointment/core/utils/routes.dart';
import 'package:doctor_appointment/core/utils/app_dimensions.dart';
import 'package:doctor_appointment/features/home/data/models/home_model.dart';
import 'package:doctor_appointment/core/utils/app_styles.dart';
import 'package:doctor_appointment/core/utils/app_colors.dart';
import 'section_header.dart';

class SpecialitiesList extends StatelessWidget {
  const SpecialitiesList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Doctor Speciality',
          onSeeAllTap: () => context.pushNamed(Routes.doctorSpecialityView),
        ),
        SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 92.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            itemCount: HomeStaticData.specialities.length,
            separatorBuilder: (_, _) => SizedBox(width: AppSpacing.md),
            itemBuilder: (_, index) =>
                SpecialityCard(speciality: HomeStaticData.specialities[index]),
          ),
        ),
      ],
    );
  }
}

class SpecialityCard extends StatelessWidget {
  const SpecialityCard({super.key, required this.speciality});

  final SpecialityModel speciality;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.pushNamed(
        Routes.recommendationView,
        extra: speciality.name,
      ),
      child: Container(
        width: 76.w,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: [
            BoxShadow(
              color: AppColors.cardShadow.withValues(alpha: 0.08),
              blurRadius: 12.r,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _SpecialityIcon(speciality: speciality),
            SizedBox(height: AppSpacing.sm),
            _SpecialityLabel(name: speciality.name),
          ],
        ),
      ),
    );
  }
}

class _SpecialityIcon extends StatelessWidget {
  const _SpecialityIcon({required this.speciality});

  final SpecialityModel speciality;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44.w,
      height: 44.h,
      decoration: BoxDecoration(
        color: speciality.bgColor,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Icon(speciality.icon, size: 22.sp, color: speciality.color),
    );
  }
}

class _SpecialityLabel extends StatelessWidget {
  const _SpecialityLabel({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Text(
      name,
      style: AppTextStyles.bodySmall.copyWith(
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
    );
  }
}
