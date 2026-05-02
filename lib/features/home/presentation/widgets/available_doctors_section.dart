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

class AvailableDoctorsSection extends StatelessWidget {
  const AvailableDoctorsSection({super.key});

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
            if (state is DoctorsSuccess || state is DoctorsPaginationLoading) {
              final page = state is DoctorsSuccess ? state.page : (state as DoctorsPaginationLoading).lastPage;
              final doctors = _mapDoctors(page.items);
              final hasNextPage = page.hasNextPage;

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
              return SizedBox(
                height: 180.h,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: doctors.length + (hasNextPage ? 1 : 0),
                  separatorBuilder: (_, _) => SizedBox(width: 12.w),
                  itemBuilder: (_, index) {
                    if (index < doctors.length) {
                      return _AvailableDoctorCard(doctor: doctors[index]);
                    } else {
                      return Container(
                        width: 130.w,
                        alignment: Alignment.center,
                        child: const CircularProgressIndicator(),
                      );
                    }
                  },
                ),
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
          'Available Doctors',
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
    Assets.imagesDrSarah,
    Assets.imagesDrNobleThorme,
    Assets.imagesDrAyeshaRahman,
  ];

  return doctors.asMap().entries.map((entry) {
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
    );
  }).toList();
}

class _AvailableDoctorCard extends StatelessWidget {
  final DoctorModel doctor;

  const _AvailableDoctorCard({required this.doctor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          AppRouter.router.push(AppRouter.kDoctorDetail, extra: doctor),
      child: Container(
        width: 160.w,
        margin: EdgeInsets.symmetric(vertical: 8.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.05),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Hero(
                    tag: 'doctor_image_avail_${doctor.id}',
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(24.r),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(24.r),
                        ),
                        child: Image.asset(
                          doctor.imageAsset,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12.h,
                    right: 12.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(10.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
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
                              fontSize: 11.sp,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doctor.name,
                    style: AppStyles.styleSemiBold22.copyWith(
                      fontSize: 14.sp,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    doctor.specialty,
                    style: AppStyles.styleRegular12.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 11.sp,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        doctor.fee != 'N/A' ? '\$${doctor.fee}' : 'Free',
                        style: AppStyles.styleBold16.copyWith(
                          color: AppColors.primary,
                          fontSize: 13.sp,
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: AppColors.primary,
                        size: 16.sp,
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

