import 'package:doctor_appointment/core/utils/app_colors.dart';
import 'package:doctor_appointment/core/utils/app_styles.dart';
import 'package:doctor_appointment/core/utils/go_router.dart';
import 'package:doctor_appointment/features/home/data/models/doctor_model.dart';
import 'package:doctor_appointment/core/services/shared_preferences_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CategoryDoctorCard extends StatelessWidget {
  final DoctorModel doctor;

  const CategoryDoctorCard({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          AppRouter.router.push(AppRouter.kDoctorDetail, extra: doctor),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.border),
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
              child: Image.asset(
                doctor.imageAsset,
                width: 65.w,
                height: 65.h,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doctor.name,
                    style: AppStyles.styleMedium14.copyWith(fontSize: 14.sp),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    doctor.specialty,
                    style: AppStyles.styleRegular12.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      Icon(
                        Icons.star_rounded,
                        color: AppColors.star,
                        size: 13.sp,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '${doctor.rating} (${doctor.reviews} Reviews)',
                        style: AppStyles.styleRegular12.copyWith(
                          color: AppColors.textSecondary,
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
                ValueListenableBuilder<int>(
                  valueListenable: SharedPreferencesHelper.favoritesVersion,
                  builder: (context, _, __) {
                    final isFavorite = SharedPreferencesHelper.isDoctorFavorite(doctor.name);
                    return GestureDetector(
                      onTap: () async => await SharedPreferencesHelper.toggleFavoriteDoctor(doctor),
                      child: Icon(
                        isFavorite ? Icons.favorite_rounded : Icons.favorite_border,
                        color: isFavorite ? AppColors.accent : AppColors.textLight,
                        size: 20.sp,
                      ),
                    );
                  },
                ),
                SizedBox(height: 12.h),
                Text(
                  doctor.fee,
                  style: AppStyles.styleMedium14.copyWith(
                    color: AppColors.primary,
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
