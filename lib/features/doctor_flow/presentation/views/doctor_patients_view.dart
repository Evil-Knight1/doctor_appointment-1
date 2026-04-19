import 'package:doctor_appointment/core/utils/app_colors.dart';
import 'package:doctor_appointment/core/utils/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DoctorPatientsView extends StatelessWidget {
  const DoctorPatientsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'My Patients',
          style: AppStyles.styleSemiBold22.copyWith(fontSize: 18.sp),
        ),
      ),
      body: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        itemCount: 8,
        separatorBuilder: (context, index) => Divider(color: AppColors.border, height: 24.h),
        itemBuilder: (context, index) {
          return Row(
            children: [
              CircleAvatar(
                radius: 24.r,
                backgroundColor: AppColors.primaryLight,
                child: Text('P\${index + 1}', style: AppStyles.styleSemiBold16.copyWith(color: AppColors.primary)),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Patient \${index + 1}', style: AppStyles.styleSemiBold16),
                    SizedBox(height: 4.h),
                    Text('Last visit: 12 Oct 2023', style: AppStyles.styleMedium14.copyWith(color: AppColors.textSecondary)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: AppColors.textLight, size: 24.sp),
            ],
          );
        },
      ),
    );
  }
}
