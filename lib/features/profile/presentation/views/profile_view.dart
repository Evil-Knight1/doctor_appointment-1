import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:doctor_appointment/core/utils/app_styles.dart';
import 'package:doctor_appointment/core/utils/go_router.dart';
import 'package:doctor_appointment/core/services/shared_preferences_helper.dart';
import 'package:doctor_appointment/core/logic/theme_cubit.dart';
import 'package:doctor_appointment/core/logic/locale_cubit.dart';
import 'package:doctor_appointment/features/profile/logic/profile_cubit.dart';
import 'package:doctor_appointment/features/profile/logic/profile_state.dart';
import 'package:doctor_appointment/features/profile/presentation/widgets/profile_header_widget.dart';
import 'package:doctor_appointment/features/profile/presentation/widgets/profile_menu_item.dart';
import 'package:doctor_appointment/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:doctor_appointment/features/profile/domain/entities/patient_profile.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = Localizations.localeOf(context);
    final String selectedLanguage = currentLocale.languageCode == 'ar'
        ? l10n.arabic
        : l10n.english;

    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          l10n.profile,
          style: AppStyles.styleSemiBold22.copyWith(fontSize: 18.sp),
        ),
      ),
      body: LiquidPullToRefresh(
        onRefresh: () => context.read<ProfileCubit>().loadProfile(),
        color: colorScheme.primary,
        backgroundColor: colorScheme.surface,
        showChildOpacityTransition: false,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 600.w),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.only(
                left: 20.w,
                right: 20.w,
                bottom: 100.h,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  BlocBuilder<ProfileCubit, ProfileState>(
                    builder: (context, state) {
                      if (state is ProfileLoading) {
                        return Skeletonizer(
                          enabled: true,
                          child: ProfileHeaderWidget(
                            profile: PatientProfile(
                              id: 0,
                              fullName: 'User Full Name',
                              email: 'user@example.com',
                              phone: '1234567890',
                              profilePicture: null,
                              dateOfBirth: DateTime.now(),
                              gender: 'Male',
                              address: 'Address',
                              createdAt: DateTime.now(),
                            ),
                          ),
                        );
                      }
                      if (state is ProfileSuccess) {
                        return ProfileHeaderWidget(profile: state.profile);
                      }
                      if (state is ProfileFailure) {
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 20.h),
                          child: Text(
                            state.message,
                            style: AppStyles.styleRegular14.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  _buildSectionLabel(l10n.account),
                  SizedBox(height: 10.h),
                  BlocBuilder<ProfileCubit, ProfileState>(
                    builder: (context, state) {
                      return ProfileMenuItem(
                        icon: Icons.person_outline_rounded,
                        title: l10n.personalInfo,
                        subtitle: l10n.personalInfoSubtitle,
                        onTap: () async {
                          if (state is! ProfileSuccess) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(l10n.seeAll),
                              ),
                            );
                            return;
                          }
                          final updated = await context.push<bool>(
                            AppRouter.kEditProfileView,
                            extra: state.profile,
                          );
                          if (!context.mounted) return;
                          if (updated == true) {
                            context.read<ProfileCubit>().loadProfile();
                          }
                        },
                      );
                    },
                  ),
                  SizedBox(height: 10.h),
                  ProfileMenuItem(
                    icon: Icons.lock_outline_rounded,
                    title: l10n.changePassword,
                    subtitle: l10n.changePasswordSubtitle,
                    onTap: () {},
                  ),
                  SizedBox(height: 20.h),
                  _buildSectionLabel(l10n.health),
                  SizedBox(height: 10.h),
                  ProfileMenuItem(
                    icon: Icons.description_outlined,
                    title: l10n.medicalRecords,
                    subtitle: l10n.medicalRecordsSubtitle,
                    onTap: () => context.push(AppRouter.kMedicalRecordsView),
                  ),
                  SizedBox(height: 10.h),
                  ProfileMenuItem(
                    icon: Icons.payment_rounded,
                    title: l10n.paymentHistory,
                    subtitle: l10n.paymentHistorySubtitle,
                    onTap: () => context.push(AppRouter.kPaymentHistoryView),
                  ),
                  SizedBox(height: 20.h),
                  _buildSectionLabel(l10n.preferences),
                  SizedBox(height: 10.h),
                  ProfileMenuItem(
                    icon: Icons.language_rounded,
                    title: l10n.language,
                    subtitle: selectedLanguage,
                    onTap: () => _showLanguagePicker(context),
                  ),
                  SizedBox(height: 10.h),
                  ProfileMenuItem(
                    icon: Icons.notifications_outlined,
                    title: l10n.notifications,
                    subtitle: _notificationsEnabled
                        ? l10n.enabled
                        : l10n.disabled,
                    trailing: Switch(
                      value: _notificationsEnabled,
                      onChanged: (v) => setState(() => _notificationsEnabled = v),
                      activeThumbColor: colorScheme.primary,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  BlocBuilder<ThemeCubit, ThemeMode>(
                    builder: (context, themeMode) {
                      return ProfileMenuItem(
                        icon: Icons.dark_mode_outlined,
                        title: l10n.darkMode,
                        subtitle: themeMode == ThemeMode.dark
                            ? l10n.enabled
                            : l10n.disabled,
                        trailing: Switch(
                          value: themeMode == ThemeMode.dark,
                          onChanged: (v) {
                            context.read<ThemeCubit>().toggleTheme(v);
                          },
                          activeThumbColor: colorScheme.primary,
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 20.h),
                  _buildSectionLabel(l10n.support),
                  SizedBox(height: 10.h),
                  ProfileMenuItem(
                    icon: Icons.help_outline_rounded,
                    title: l10n.helpSupport,
                    onTap: () {},
                  ),
                  SizedBox(height: 10.h),
                  ProfileMenuItem(
                    icon: Icons.privacy_tip_outlined,
                    title: l10n.privacyPolicy,
                    onTap: () {},
                  ),
                  SizedBox(height: 20.h),
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
                            style: AppStyles.styleMedium14.copyWith(
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
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: AppStyles.styleSemiBold22.copyWith(fontSize: 14.sp),
      ),
    );
  }

  void _showLanguagePicker(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = Localizations.localeOf(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              l10n.selectLanguage,
              style: AppStyles.styleSemiBold22.copyWith(fontSize: 16.sp),
            ),
            SizedBox(height: 16.h),
            _LanguageOption(
              label: l10n.english,
              isSelected: currentLocale.languageCode == 'en',
              onTap: () {
                context.read<LocaleCubit>().changeLocale('en');
                Navigator.pop(context);
              },
            ),
            _LanguageOption(
              label: l10n.arabic,
              isSelected: currentLocale.languageCode == 'ar',
              onTap: () {
                context.read<LocaleCubit>().changeLocale('ar');
                Navigator.pop(context);
              },
            ),
            SizedBox(height: 8.h),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          l10n.logout,
          style: AppStyles.styleSemiBold22.copyWith(fontSize: 16.sp),
        ),
        content: Text(
          l10n.logoutConfirm,
          style: AppStyles.styleRegular14.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.cancel,
              style: AppStyles.styleMedium14.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
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
              l10n.logout,
              style: AppStyles.styleMedium14.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppStyles.styleMedium14),
            if (isSelected)
              Icon(
                Icons.check_rounded,
                color: Theme.of(context).colorScheme.primary,
                size: 18.sp,
              ),
          ],
        ),
      ),
    );
  }
}
