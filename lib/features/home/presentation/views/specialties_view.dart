import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:doctor_appointment/core/utils/app_colors.dart';
import 'package:doctor_appointment/core/utils/app_images.dart';
import 'package:doctor_appointment/core/utils/app_styles.dart';
import 'package:doctor_appointment/core/utils/go_router.dart';

class SpecialtiesView extends StatelessWidget {
  const SpecialtiesView({super.key});

  static final List<Map<String, String>> _allSpecialties = [
    {'label': 'Dentist', 'asset': Assets.imagesDentist},
    {'label': 'Ophthalmologist', 'asset': Assets.imagesOphthalmologist},
    {'label': 'ENT Specialist', 'asset': Assets.imagesENTSpecialist},
    {'label': 'Otologist', 'asset': Assets.imagesOtologist},
    {'label': 'Cardiologist', 'asset': Assets.imagesStethoscope},
    {'label': 'Neurologist', 'asset': Assets.imagesStethoscope}, 
    {'label': 'Pediatrician', 'asset': Assets.imagesStethoscope},
    {'label': 'Dermatologist', 'asset': Assets.imagesStethoscope},
    {'label': 'Surgeon', 'asset': Assets.imagesStethoscope},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: Container(
            margin: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: AppColors.bg,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary,
              size: 16.sp,
            ),
          ),
        ),
        title: Text(
          'All Specialties',
          style: AppStyles.styleSemiBold22.copyWith(fontSize: 18.sp),
        ),
      ),
      body: GridView.builder(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 16.w,
          mainAxisSpacing: 24.h,
          childAspectRatio: 0.8, // Adjust box size
        ),
        itemCount: _allSpecialties.length,
        itemBuilder: (context, index) {
          final s = _allSpecialties[index];
          return GestureDetector(
            onTap: () => context.push(AppRouter.kCategoryDetailsView, extra: s['label']),
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Center(
                      child: SvgPicture.asset(s['asset']!, width: 35.w, height: 35.h),
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  s['label']!,
                  textAlign: TextAlign.center,
                  style: AppStyles.styleRegular12.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 12.sp,
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
