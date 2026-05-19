import 'package:doctor_appointment/core/theme/app_theme_extension.dart';

import 'package:doctor_appointment/core/utils/go_router.dart';
import 'package:doctor_appointment/features/doctor_flow/logic/doctor_profile_cubit.dart';
import 'package:doctor_appointment/features/doctor_flow/logic/doctor_profile_state.dart';
import 'package:doctor_appointment/features/doctor_flow/logic/doctor_availability_cubit.dart';
import 'package:doctor_appointment/features/doctor_flow/presentation/views/doctor_availability_view.dart';
import 'package:doctor_appointment/features/profile/presentation/widgets/profile_menu_item.dart';
import 'package:doctor_appointment/core/services/shared_preferences_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';

class DoctorProfileView extends StatefulWidget {
  const DoctorProfileView({super.key});

  @override
  State<DoctorProfileView> createState() => _DoctorProfileViewState();
}

class _DoctorProfileViewState extends State<DoctorProfileView> {
  @override
  void initState() {
    super.initState();
    context.read<DoctorProfileCubit>().fetchProfile();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Doctor Profile',
          style: context.styleSemiBold22.copyWith(fontSize: 18.sp, color: colorScheme.onSurface),
        ),
      ),
      body: BlocListener<DoctorProfileCubit, DoctorProfileState>(
        listener: (context, state) {
          if (state is DoctorProfileFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: colorScheme.error,
              ),
            );
          }
        },
        child: BlocBuilder<DoctorProfileCubit, DoctorProfileState>(
          builder: (context, state) {
            final isLoading = state is DoctorProfileLoading;
            final doctor = state is DoctorProfileSuccess ? state.doctor : null;

            return Skeletonizer(
              enabled: isLoading,
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  children: [
                    SizedBox(height: 20.h),
                    CircleAvatar(
                      radius: 40.r,
                      backgroundColor: colorScheme.primaryContainer,
                      child: Icon(
                        Icons.person,
                        size: 40.sp,
                        color: colorScheme.primary,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      doctor?.fullName ?? 'Doctor Full Name',
                      style: context.styleSemiBold22.copyWith(color: colorScheme.onSurface),
                    ),
                    Text(
                      doctor?.specialization.name ?? 'Specialization',
                      style: context.styleRegular14.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                    SizedBox(height: 32.h),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Management',
                        style: context.styleSemiBold16.copyWith(color: colorScheme.onSurface),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    ProfileMenuItem(
                      icon: Icons.personal_injury_outlined,
                      title: 'Accepting Patients',
                      subtitle: (doctor?.isAvailable ?? true)
                          ? 'Currently Accepting'
                          : 'Not Accepting',
                      trailing: Switch(
                        value: doctor?.isAvailable ?? true,
                        onChanged: (v) {
                          context
                              .read<DoctorProfileCubit>()
                              .updateAcceptingPatients(v);
                        },
                        activeThumbColor: colorScheme.primary,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    ProfileMenuItem(
                      icon: Icons.payments_outlined,
                      title: 'Setup Fees & Services',
                      subtitle: 'Manage your consultation costs',
                      onTap: () {
                        if (doctor != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BlocProvider.value(
                                value: context.read<DoctorAvailabilityCubit>(),
                                child: DoctorAvailabilityView(doctorId: doctor.id),
                              ),
                            ),
                          );
                        }
                      },
                    ),
                    SizedBox(height: 12.h),
                    ProfileMenuItem(
                      icon: Icons.access_time_rounded,
                      title: 'Working Hours',
                      subtitle: 'Set auto-schedule blocks',
                      onTap: () {
                        if (doctor != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BlocProvider.value(
                                value: context.read<DoctorAvailabilityCubit>(),
                                child: DoctorAvailabilityView(doctorId: doctor.id),
                              ),
                            ),
                          );
                        }
                      },
                    ),
                    SizedBox(height: 32.h),
                    GestureDetector(
                      onTap: () => _showLogoutDialog(context),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        decoration: BoxDecoration(
                          color: colorScheme.error.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(
                            color: colorScheme.error.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.logout_rounded,
                              color: colorScheme.error,
                              size: 20.sp,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              'Log Out',
                              style: context.styleMedium14.copyWith(
                                color: colorScheme.error,
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
              ),
            );
          },
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          'Log Out',
          style: context.styleSemiBold22.copyWith(fontSize: 16.sp, color: colorScheme.onSurface),
        ),
        content: Text(
          'Are you sure you want to log out?',
          style: context.styleRegular14.copyWith(color: colorScheme.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: context.styleMedium14.copyWith(color: colorScheme.onSurfaceVariant),
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
              style: context.styleMedium14.copyWith(color: colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}
