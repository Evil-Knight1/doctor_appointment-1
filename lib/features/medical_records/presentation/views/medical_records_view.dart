import 'package:doctor_appointment/core/utils/app_colors.dart';
import 'package:doctor_appointment/core/utils/app_styles.dart';
import 'package:doctor_appointment/core/utils/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class MedicalRecordsView extends StatelessWidget {
  const MedicalRecordsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20.sp),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Medical Records',
          style: AppStyles.styleSemiBold22.copyWith(fontSize: 18.sp),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRouter.kCreateRecordView),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
      body: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        itemCount: 4,
        separatorBuilder: (context, index) => SizedBox(height: 12.h),
        itemBuilder: (context, index) {
          return _buildRecordCard(index);
        },
      ),
    );
  }

  Widget _buildRecordCard(int index) {
    final titles = [
      'Blood Test Results',
      'Dental X-Ray',
      'General Checkup',
      'Eye Vision Prescription'
    ];
    final dates = ['12 Oct, 2023', '05 Sep, 2023', '14 Jul, 2023', '22 Jan, 2023'];
    final icons = [
      Icons.bloodtype_outlined,
      Icons.masks_outlined,
      Icons.health_and_safety_outlined,
      Icons.remove_red_eye_outlined
    ];
    final docs = ['Dr. Sarah', 'Dr. Ayesha Rahman', 'Dr. Noble Thorme', 'Dr. Sarah'];
    
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icons[index % icons.length], color: AppColors.primary, size: 24.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titles[index % titles.length],
                  style: AppStyles.styleSemiBold16,
                ),
                SizedBox(height: 4.h),
                Text(
                  'Added by ${docs[index % docs.length]}',
                  style: AppStyles.styleMedium14.copyWith(color: AppColors.textSecondary),
                ),
                SizedBox(height: 4.h),
                Text(
                  dates[index % dates.length],
                  style: AppStyles.styleRegular12.copyWith(color: AppColors.textLight),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary, size: 24.sp),
        ],
      ),
    );
  }
}
