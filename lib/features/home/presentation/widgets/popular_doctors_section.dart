import 'package:doctor_appointment/core/utils/app_colors.dart';
import 'package:doctor_appointment/core/utils/app_images.dart';
import 'package:doctor_appointment/core/utils/app_styles.dart';
import 'package:doctor_appointment/core/utils/go_router.dart';
import 'package:doctor_appointment/features/doctors/domain/entities/doctor.dart';
import 'package:doctor_appointment/features/doctors/logic/doctors_cubit.dart';
import 'package:doctor_appointment/features/doctors/logic/doctors_state.dart';
import 'package:doctor_appointment/features/home/data/models/doctor_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:doctor_appointment/core/services/shared_preferences_helper.dart';

class PopularDoctorsSection extends StatelessWidget {
  const PopularDoctorsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSectionHeader(),
        SizedBox(height: 14.h),
        BlocBuilder<DoctorsCubit, DoctorsState>(
          builder: (context, state) {
            if (state is DoctorsLoading) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                child: const Center(child: CircularProgressIndicator()),
              );
            }
            if (state is DoctorsFailure) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                child: Text(
                  state.message,
                  style: AppStyles.styleRegular12.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              );
            }
            if (state is DoctorsSuccess) {
              final doctors = _mapDoctors(state.page.items);
              if (doctors.isEmpty) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  child: Text(
                    'No doctors found.',
                    style: AppStyles.styleRegular12.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                );
              }
              return Column(
                children: doctors
                    .map(
                      (doctor) => Padding(
                        padding: EdgeInsets.only(bottom: 12.h),
                        child: _PopularDoctorCard(doctor: doctor),
                      ),
                    )
                    .toList(),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildSectionHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Popular Doctors',
          style: AppStyles.styleSemiBold22.copyWith(fontSize: 16.sp),
        ),
        GestureDetector(
          onTap: () => AppRouter.router.push(AppRouter.kCategoryDetailsView),
          child: Text(
            'See all',
            style: AppStyles.styleRegular14.copyWith(color: AppColors.primary),
          ),
        ),
      ],
    );
  }
}

List<DoctorModel> _mapDoctors(List<Doctor> doctors) {
  final images = [
    Assets.imagesDrAyeshaRahman,
    Assets.imagesDrNobleThorme,
    Assets.imagesDrSarah,
  ];

  final sorted = [...doctors]
    ..sort((a, b) => (b.averageRating ?? 0).compareTo(a.averageRating ?? 0));
  final top = sorted.take(2).toList();

  return top.asMap().entries.map((entry) {
    final index = entry.key;
    final doctor = entry.value;
    return DoctorModel(
      id: doctor.id,
      name: doctor.fullName,
      specialty: doctor.specialization ?? 'General',
      rating: doctor.averageRating ?? 0,
      reviews: doctor.totalReviews,
      fee: 'N/A',
      imageAsset: images[index % images.length],
      isFavorite: index == 0,
    );
  }).toList();
}

class _PopularDoctorCard extends StatelessWidget {
  final DoctorModel doctor;

  const _PopularDoctorCard({required this.doctor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          AppRouter.router.push(AppRouter.kDoctorDetail, extra: doctor),
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.05),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Hero(
              tag: 'doctor_image_${doctor.id}',
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.r),
                  child: Image.asset(
                    doctor.imageAsset,
                    width: 80.w,
                    height: 80.h,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          doctor.name,
                          style: AppStyles.styleSemiBold22.copyWith(
                            fontSize: 16.sp,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      ValueListenableBuilder<int>(
                        valueListenable:
                            SharedPreferencesHelper.favoritesVersion,
                        builder: (context, _, _) {
                          final isFavorite =
                              SharedPreferencesHelper.isDoctorFavorite(
                                doctor.name,
                              );
                          return GestureDetector(
                            onTap: () async =>
                                await SharedPreferencesHelper
                                    .toggleFavoriteDoctor(doctor),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              padding: EdgeInsets.all(6.w),
                              decoration: BoxDecoration(
                                color:
                                    isFavorite
                                        ? AppColors.accent.withValues(
                                          alpha: 0.1,
                                        )
                                        : Colors.grey.withValues(alpha: 0.05),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isFavorite
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border,
                                color:
                                    isFavorite
                                        ? AppColors.accent
                                        : AppColors.textLight,
                                size: 18.sp,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      doctor.specialty,
                      style: AppStyles.styleMedium14.copyWith(
                        color: AppColors.primary,
                        fontSize: 11.sp,
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.star.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.star_rounded,
                              color: AppColors.star,
                              size: 14.sp,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              '${doctor.rating}',
                              style: AppStyles.styleBold16.copyWith(
                                fontSize: 12.sp,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        '(${doctor.reviews} Reviews)',
                        style: AppStyles.styleRegular12.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 11.sp,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        doctor.fee != 'N/A' ? '\$${doctor.fee}' : 'Free',
                        style: AppStyles.styleBold16.copyWith(
                          color: AppColors.primary,
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

