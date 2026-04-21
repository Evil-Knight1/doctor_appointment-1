import 'package:doctor_appointment/core/utils/app_colors.dart';
import 'package:doctor_appointment/core/utils/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppointmentCard extends StatelessWidget {
  final String name;
  final String specialty;
  final String date;
  final String time;
  final String imageAsset;
  final bool isCompleted;
  final bool isCancelled;

  const AppointmentCard({
    super.key,
    required this.name,
    required this.specialty,
    required this.date,
    required this.time,
    required this.imageAsset,
    this.isCompleted = false,
    this.isCancelled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
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
      child: Column(
        children: [
          _buildDoctorRow(),
          SizedBox(height: 12.h),
          Divider(color: AppColors.border, height: 1),
          SizedBox(height: 12.h),
          _buildActions(),
        ],
      ),
    );
  }

  Widget _buildDoctorRow() {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: Image.asset(
            imageAsset,
            width: 55.w,
            height: 55.w,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(
              width: 55.w,
              height: 55.w,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(Icons.person, color: AppColors.primary, size: 28.sp),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: AppStyles.styleMedium14.copyWith(fontSize: 14.sp),
              ),
              SizedBox(height: 2.h),
              Text(
                specialty,
                style: AppStyles.styleRegular12.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 6.h),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    date,
                    style: AppStyles.styleRegular12.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 11.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Icon(
                    Icons.access_time_rounded,
                    size: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    time,
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
      ],
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
              padding: EdgeInsets.symmetric(vertical: 10.h),
            ),
            child: Text(
              'Re-book',
              style: AppStyles.styleMedium14.copyWith(
                color: AppColors.primary,
                fontSize: 12.sp,
              ),
            ),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: isCompleted || isCancelled
                  ? AppColors.accent
                  : AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
              padding: EdgeInsets.symmetric(vertical: 10.h),
              elevation: 0,
            ),
            child: Text(
              isCompleted || isCancelled ? 'Leave Review' : 'Cancel',
              style: AppStyles.styleMedium14.copyWith(
                color: Colors.white,
                fontSize: 12.sp,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
