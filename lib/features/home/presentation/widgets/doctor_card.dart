import 'package:skeletonizer/skeletonizer.dart';
import 'package:doctor_appointment/core/utils/image_url_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:doctor_appointment/core/utils/routes.dart';
import 'package:doctor_appointment/core/utils/app_dimensions.dart';
import 'package:doctor_appointment/features/home/data/models/home_doctor_model.dart';
import 'package:doctor_appointment/core/theme/app_theme_extension.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'star_rating.dart';

class DoctorCard extends StatelessWidget {
  const DoctorCard({
    super.key,
    required this.doctor,
    this.heroTag,
  });

  final HomeDoctorModel doctor;
  final String? heroTag;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 16.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: InkWell(
          onTap: () =>
              context.pushNamed(
                Routes.doctorDetailsView,
                extra: {
                  'doctor': doctor,
                  'heroTag': resolvedHeroTag,
                },
              ),
          borderRadius: BorderRadius.circular(AppRadius.xl),
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                _DoctorAvatar(doctor: doctor, heroTag: resolvedHeroTag),
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

  String get resolvedHeroTag => heroTag ?? 'doctor-${doctor.id}';
}

class _DoctorAvatar extends StatelessWidget {
  const _DoctorAvatar({required this.doctor, required this.heroTag});

  final HomeDoctorModel doctor;
  final String heroTag;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final customColors = context.customColors;

    return Stack(
      children: [
        Hero(
          tag: heroTag,
          child: Container(
            width: 64.w,
            height: 64.h,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            clipBehavior: Clip.antiAlias,
            child: doctor.imageAsset.startsWith('http')
                ? CachedNetworkImage(
                    imageUrl: doctor.imageAsset,
                    httpHeaders: ImageUrlHelper.getImageHeaders(),
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Skeletonizer(
                      enabled: true,
                      child: Container(
                        width: 64.w,
                        height: 64.h,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Icon(
                      Icons.person_rounded,
                      size: 36.sp,
                      color: colorScheme.primary,
                    ),
                  )
                : Image.asset(doctor.imageAsset, fit: BoxFit.cover),
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
                color: customColors.doctorOnline ?? Colors.green,
                shape: BoxShape.circle,
                border: Border.all(color: colorScheme.surface, width: 2.w),
              ),
            ),
          ),
      ],
    );
  }
}

class _DoctorInfo extends StatelessWidget {
  const _DoctorInfo({required this.doctor});

  final HomeDoctorModel doctor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          doctor.name,
          style: context.headingMedium.copyWith(color: colorScheme.onSurface),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 2.h),
        Text(
          '${doctor.speciality} | ${doctor.hospital}',
          style: context.bodySmall.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
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
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 36.w,
      height: 36.h,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Icon(
        Icons.bookmark_outline_rounded,
        size: 18.sp,
        color: colorScheme.onSurfaceVariant,
      ),
    );
  }
}
