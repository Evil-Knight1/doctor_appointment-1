import 'package:skeletonizer/skeletonizer.dart';
import 'package:doctor_appointment/core/utils/image_url_helper.dart';
import 'package:doctor_appointment/core/utils/app_styles.dart';
import 'package:doctor_appointment/core/utils/routes.dart';
import 'package:doctor_appointment/features/home/data/models/home_doctor_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';

import 'package:doctor_appointment/core/theme/app_theme_extension.dart';

class FavoriteDoctorCard extends StatelessWidget {
  final HomeDoctorModel doctor;
  final VoidCallback onRemove;

  const FavoriteDoctorCard({
    super.key,
    required this.doctor,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final customColors = context.customColors;
    return GestureDetector(
      onTap: () => context.pushNamed(Routes.doctorDetailsView, extra: doctor),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: colorScheme.outlineVariant),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: CachedNetworkImage(
                imageUrl: ImageUrlHelper.getFullUrl(
                  doctor.doctor.profilePictureUrl,
                ),
                httpHeaders: ImageUrlHelper.getImageHeaders(),
                width: 65.w,
                height: 65.h,
                fit: BoxFit.cover,
                placeholder: (context, url) => Skeletonizer(
                  enabled: true,
                  child: Container(
                    width: 65.w,
                    height: 65.h,
                    color: colorScheme.surfaceContainer,
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  width: 65.w,
                  height: 65.h,
                  color: colorScheme.surfaceContainer,
                  child: Icon(
                    Icons.person,
                    color: colorScheme.primary,
                    size: 30.sp,
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doctor.name,
                    style: AppStyles.styleMedium14.copyWith(
                      fontSize: 14.sp,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    doctor.doctor.specialization.name,
                    style: AppStyles.styleRegular12.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      Icon(
                        Icons.star_rounded,
                        color: customColors.rating,
                        size: 13.sp,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '${doctor.rating} (${doctor.reviewCount} Reviews)',
                        style: AppStyles.styleRegular12.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 11.sp,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: onRemove,
                  child: Icon(
                    Icons.favorite_rounded,
                    color: colorScheme.tertiary,
                    size: 22.sp,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  '\$${doctor.doctor.consultationFee ?? 100}',
                  style: AppStyles.styleMedium14.copyWith(
                    color: colorScheme.primary,
                    fontSize: 13.sp,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
