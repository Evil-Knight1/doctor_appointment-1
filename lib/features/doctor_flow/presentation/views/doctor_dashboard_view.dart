import 'package:doctor_appointment/core/utils/app_colors.dart';
import 'package:doctor_appointment/core/utils/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DoctorDashboardView extends StatelessWidget {
  const DoctorDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Dashboard',
          style: AppStyles.styleSemiBold22.copyWith(fontSize: 18.sp),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome back, Dr. Smith', style: AppStyles.styleSemiBold22),
            SizedBox(height: 8.h),
            Text('Have a nice day at work!', style: AppStyles.styleRegular14.copyWith(color: AppColors.textSecondary)),
            SizedBox(height: 24.h),
            Row(
              children: [
                Expanded(child: _buildStatCard('Patients', '241', Icons.people_alt_rounded, AppColors.primary)),
                SizedBox(width: 16.w),
                Expanded(child: _buildStatCard('Revenue', '\$4.2k', Icons.attach_money_rounded, AppColors.green)),
              ],
            ),
            SizedBox(height: 24.h),
            Text('Next Appointment', style: AppStyles.styleSemiBold16),
            SizedBox(height: 12.h),
            _buildNextAppointmentCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, color: color, size: 24.sp),
          ),
          SizedBox(height: 12.h),
          Text(value, style: AppStyles.styleSemiBold22),
          SizedBox(height: 4.h),
          Text(title, style: AppStyles.styleMedium14.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildNextAppointmentCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24.r,
            backgroundColor: AppColors.primary,
            child: Text('AS', style: AppStyles.styleSemiBold16.copyWith(color: Colors.white)),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ahmed Salem', style: AppStyles.styleSemiBold16),
                SizedBox(height: 4.h),
                Text('Today, 10:30 AM', style: AppStyles.styleMedium14.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          Icon(Icons.video_camera_front_rounded, color: AppColors.primary, size: 28.sp),
        ],
      ),
    );
  }
}

