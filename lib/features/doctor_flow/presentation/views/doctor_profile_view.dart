import 'package:doctor_appointment/core/utils/app_colors.dart';
import 'package:doctor_appointment/core/utils/app_styles.dart';
import 'package:doctor_appointment/core/utils/go_router.dart';
import 'package:doctor_appointment/features/doctor_flow/logic/doctor_profile_cubit.dart';
import 'package:doctor_appointment/features/doctor_flow/logic/doctor_profile_state.dart';
import 'package:doctor_appointment/features/profile/presentation/widgets/profile_menu_item.dart';
import 'package:doctor_appointment/core/services/shared_preferences_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class DoctorProfileView extends StatefulWidget {
  const DoctorProfileView({super.key});

  @override
  State<DoctorProfileView> createState() => _DoctorProfileViewState();
}

class _DoctorProfileViewState extends State<DoctorProfileView> {
  bool _isAcceptingNewPatients = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Doctor Profile',
          style: AppStyles.styleSemiBold22.copyWith(fontSize: 18.sp),
        ),
      ),
      body: BlocBuilder<DoctorProfileCubit, DoctorProfileState>(
        builder: (context, state) {
          if (state is DoctorProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is DoctorProfileFailure) {
            return Center(child: Text(state.message));
          } else if (state is DoctorProfileSuccess) {
            final doctor = state.doctor;
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                children: [
                  SizedBox(height: 20.h),
                  CircleAvatar(
                    radius: 40.r,
                    backgroundColor: AppColors.primaryLight,
                    child: Icon(
                      Icons.person,
                      size: 40.sp,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(doctor.fullName, style: AppStyles.styleSemiBold22),
                  Text(
                    doctor.specialization ?? 'Specialist',
                    style: AppStyles.styleRegular14.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 32.h),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Management', style: AppStyles.styleSemiBold16),
                  ),
                  SizedBox(height: 12.h),
                  ProfileMenuItem(
                    icon: Icons.personal_injury_outlined,
                    title: 'Accepting Patients',
                    subtitle: _isAcceptingNewPatients
                        ? 'Currently Accepting'
                        : 'Not Accepting',
                    trailing: Switch(
                      value: _isAcceptingNewPatients,
                      onChanged: (v) =>
                          setState(() => _isAcceptingNewPatients = v),
                      activeThumbColor: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  ProfileMenuItem(
                    icon: Icons.payments_outlined,
                    title: 'Setup Fees & Services',
                    subtitle: 'Manage your consultation costs',
                    onTap: () {},
                  ),
                  SizedBox(height: 12.h),
                  ProfileMenuItem(
                    icon: Icons.access_time_rounded,
                    title: 'Working Hours',
                    subtitle: 'Set auto-schedule blocks',
                    onTap: () {},
                  ),
                  SizedBox(height: 32.h),
                  GestureDetector(
                    onTap: () => _showLogoutDialog(context),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(
                          color: AppColors.accent.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.logout_rounded,
                            color: AppColors.accent,
                            size: 20.sp,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'Log Out',
                            style: AppStyles.styleMedium14.copyWith(
                              color: AppColors.accent,
                              fontSize: 15.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 32.h),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          'Log Out',
          style: AppStyles.styleSemiBold22.copyWith(fontSize: 16.sp),
        ),
        content: Text(
          'Are you sure you want to log out?',
          style: AppStyles.styleRegular14.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppStyles.styleMedium14.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              await SharedPreferencesHelper.clearAll();
              if (context.mounted) {
                context.go(AppRouter.kLoginView);
              }
            },
            child: Text(
              'Log Out',
              style: AppStyles.styleMedium14.copyWith(color: AppColors.accent),
            ),
          ),
        ],
      ),
    );
  }
}
