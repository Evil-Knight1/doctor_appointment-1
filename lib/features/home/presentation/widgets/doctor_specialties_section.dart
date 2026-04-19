import 'package:doctor_appointment/core/utils/app_colors.dart';
import 'package:doctor_appointment/core/utils/app_images.dart';
import 'package:doctor_appointment/core/utils/app_styles.dart';
import 'package:doctor_appointment/core/utils/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class DoctorSpecialtiesSection extends StatelessWidget {
  const DoctorSpecialtiesSection({super.key});

  static final List<Map<String, String>> _specialties = [
    {'label': 'Dentist', 'asset': Assets.imagesDentist},
    {'label': 'Ophthalmologist', 'asset': Assets.imagesOphthalmologist},
    {'label': 'ENT\nSpecialist', 'asset': Assets.imagesENTSpecialist},
    {'label': 'Otologist', 'asset': Assets.imagesOtologist},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSectionHeader(context),
        SizedBox(height: 14.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: _specialties
              .map(
                (s) => GestureDetector(
                  onTap: () => context.push(AppRouter.kCategoryDetailsView, extra: s['label']!.replaceAll('\n', ' ')),
                  child: _SpecialtyItem(label: s['label']!, asset: s['asset']!),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Doctor Specialties',
          style: AppStyles.styleSemiBold22.copyWith(fontSize: 16.sp),
        ),
        GestureDetector(
          onTap: () => context.push(AppRouter.kSpecialtiesView),
          child: Text(
            'See all',
            style: AppStyles.styleRegular14.copyWith(color: AppColors.primary),
          ),
        ),
      ],
    );
  }
}

class _SpecialtyItem extends StatelessWidget {
  final String label;
  final String asset;

  const _SpecialtyItem({required this.label, required this.asset});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 60.w,
          height: 60.h,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Center(
            child: SvgPicture.asset(asset, width: 30.w, height: 30.h),
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          label,
          textAlign: TextAlign.center,
          style: AppStyles.styleRegular12.copyWith(
            color: AppColors.textSecondary,
            fontSize: 11.sp,
          ),
        ),
      ],
    );
  }
}
