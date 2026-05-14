import 'package:doctor_appointment/core/theme/app_theme_extension.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:doctor_appointment/core/utils/image_url_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:doctor_appointment/core/utils/app_dimensions.dart';
import 'package:doctor_appointment/features/home/data/models/home_doctor_model.dart';
import 'package:doctor_appointment/core/utils/app_styles.dart';
import 'package:cached_network_image/cached_network_image.dart';

class DoctorBottomCard extends StatelessWidget {
  const DoctorBottomCard({
    super.key,
    required this.doctor,
    required this.onTap,
  });
  final HomeDoctorModel doctor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.all(AppSpacing.lg),
        padding: EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.12),
              blurRadius: 20.r,
              offset: Offset(0, -4.h),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56.w,
              height: 56.h,
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
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
                          width: 56.w,
                          height: 56.h,
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Icon(
                        Icons.person_rounded,
                        color: colorScheme.primary,
                        size: 32.sp,
                      ),
                    )
                  : Image.asset(doctor.imageAsset, fit: BoxFit.cover),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(doctor.name,
                      style: context.headingMedium
                          .copyWith(color: colorScheme.onSurface)),
                  Text(
                    '${doctor.speciality} | ${doctor.hospital}',
                    style: context.bodySmall
                        .copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(
                        Icons.star_rounded,
                        size: 13.sp,
                        color: context.customColors.rating,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        '${doctor.rating} (${doctor.reviewCount} reviews)',
                        style: context.bodySmall
                            .copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14.sp,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
            ),
          ],
        ),
      ),
    );
  }
}
