import 'package:doctor_appointment/core/theme/app_theme_extension.dart';

import 'package:doctor_appointment/core/utils/go_router.dart';
import 'package:doctor_appointment/features/doctor_flow/logic/doctor_profile_cubit.dart';
import 'package:doctor_appointment/features/doctor_flow/logic/doctor_profile_state.dart';
import 'package:doctor_appointment/features/doctor_flow/logic/doctor_availability_cubit.dart';
import 'package:doctor_appointment/features/doctor_flow/presentation/views/doctor_availability_view.dart';
import 'package:doctor_appointment/features/profile/presentation/widgets/profile_menu_item.dart';
import 'package:doctor_appointment/core/services/shared_preferences_helper.dart';
import 'package:doctor_appointment/core/services/app_cache_service.dart';
import 'package:doctor_appointment/core/services/chat_cache_service.dart';
import 'package:doctor_appointment/core/services/service_locator.dart';
import 'package:doctor_appointment/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:doctor_appointment/core/utils/image_url_helper.dart';

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
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          l10n.doctorProfile,
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
                      backgroundImage: doctor?.profilePictureUrl != null
                          ? CachedNetworkImageProvider(
                              ImageUrlHelper.getFullUrl(doctor!.profilePictureUrl!),
                            )
                          : null,
                      child: doctor?.profilePictureUrl == null
                          ? Icon(
                              Icons.person,
                              size: 40.sp,
                              color: colorScheme.primary,
                            )
                          : null,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      doctor?.fullName ?? l10n.doctorFullName,
                      style: context.styleSemiBold22.copyWith(color: colorScheme.onSurface),
                    ),
                    Text(
                      doctor?.specialization.name ?? l10n.specialization,
                      style: context.styleRegular14.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                    SizedBox(height: 32.h),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        l10n.management,
                        style: context.styleSemiBold16.copyWith(color: colorScheme.onSurface),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    ProfileMenuItem(
                      icon: Icons.personal_injury_outlined,
                      title: l10n.acceptingPatients,
                      subtitle: (doctor?.isAvailable ?? true)
                          ? l10n.currentlyAccepting
                          : l10n.notAccepting,
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
                      title: l10n.setupFeesAndServices,
                      subtitle: l10n.manageConsultationCosts,
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
                      title: l10n.workingHours,
                      subtitle: l10n.setAutoScheduleBlocks,
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
                      icon: Icons.language_rounded,
                      title: l10n.language,
                      subtitle: l10n.english,
                      onTap: () {},
                    ),
                    SizedBox(height: 12.h),
                    ProfileMenuItem(
                      icon: Icons.dark_mode_outlined,
                      title: l10n.appearance,
                      subtitle: l10n.systemDefault,
                      onTap: () {},
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
                              l10n.logout,
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
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          l10n.logout,
          style: context.styleSemiBold22.copyWith(fontSize: 16.sp, color: colorScheme.onSurface),
        ),
        content: Text(
          l10n.logoutConfirm,
          style: context.styleRegular14.copyWith(color: colorScheme.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.cancel,
              style: context.styleMedium14.copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ),
          TextButton(
            onPressed: () async {
              await SharedPreferencesHelper.clearAll();
              await getIt<AppCacheService>().clearAll();
              await getIt<ChatCacheService>().clearAll();
              if (context.mounted) {
                context.go(AppRouter.kLoginView);
              }
            },
            child: Text(
              l10n.logout,
              style: context.styleMedium14.copyWith(color: colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}
