import 'package:doctor_appointment/core/utils/app_colors.dart';
import 'package:doctor_appointment/core/utils/app_styles.dart';
import 'package:doctor_appointment/features/home/data/models/doctor_model.dart';
import 'package:doctor_appointment/features/doctor_details/presentation/widgets/doctor_info_widget.dart';
import 'package:doctor_appointment/features/doctor_details/presentation/widgets/doctor_stats_widget.dart';
import 'package:doctor_appointment/features/doctor_details/presentation/widgets/doctor_working_time_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class DoctorDetailsView extends StatelessWidget {
  final DoctorModel doctor;
  const DoctorDetailsView({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                DoctorInfoWidget(doctor: doctor),
                const DoctorStatsWidget(),
                SizedBox(height: 20.h),
                _buildAbout(),
                SizedBox(height: 20.h),
                const DoctorWorkingTimeWidget(),
                SizedBox(height: 100.h),
              ],
            ),
          ),
          _buildBottomButton(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 300.h,
          color: AppColors.primaryLight,
          child: Image.asset(
            doctor.imageAsset,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) =>
                Icon(Icons.person, size: 80.sp, color: AppColors.primary),
          ),
        ),
        Positioned(
          top: 48.h,
          left: 20.w,
          child: GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 36.w,
              height: 36.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16.sp,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
        Positioned(
          top: 52.h,
          left: 0,
          right: 0,
          child: Center(
            child: Text(
              doctor.name,
              style: AppStyles.styleMedium14.copyWith(fontSize: 15.sp),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAbout() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About',
            style: AppStyles.styleSemiBold22.copyWith(fontSize: 16.sp),
          ),
          SizedBox(height: 8.h),
          Text(
            'Lorem ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.',
            style: AppStyles.styleRegular14.copyWith(
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 32.h),
        color: Colors.white,
        child: ElevatedButton(
          onPressed: () => context.push('/newAppointment', extra: doctor),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14.r),
            ),
            minimumSize: Size(double.infinity, 52.h),
            elevation: 0,
          ),
          child: Text('Book Appointment', style: AppStyles.styleSemiBold16),
        ),
      ),
    );
  }
}
