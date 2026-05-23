import 'package:doctor_appointment/core/theme/app_theme_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:doctor_appointment/core/utils/go_router.dart';
import 'package:doctor_appointment/core/services/shared_preferences_helper.dart';
import 'package:doctor_appointment/core/services/app_cache_service.dart';
import 'package:doctor_appointment/core/services/chat_cache_service.dart';
import 'package:doctor_appointment/core/services/service_locator.dart';
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
          style: context.styleSemiBold22.copyWith(fontSize: 18.sp),
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
              padding: EdgeInsets.only(left: 20.w, right: 20.w, bottom: 100.h),
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
                            style: context.styleRegular14.copyWith(
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
                              SnackBar(content: Text(l10n.seeAll)),
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
                      onChanged: (v) =>
                          setState(() => _notificationsEnabled = v),
                      activeThumbColor: colorScheme.primary,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  BlocBuilder<ThemeCubit, ThemeMode>(
                    builder: (context, themeMode) {
                      return ProfileMenuItem(
                        icon: Icons.palette_outlined,
                        title: l10n.appearance,
                        subtitle: themeMode == ThemeMode.system
                            ? l10n.systemDefault
                            : (themeMode == ThemeMode.dark ? l10n.darkMode : l10n.lightMode),
                        trailing: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: colorScheme.onSurfaceVariant,
                          size: 20.sp,
                        ),
                        onTap: () async {
                          final RenderBox button = context.findRenderObject() as RenderBox;
                          final RenderBox overlay = Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
                          final RelativeRect position = RelativeRect.fromRect(
                            Rect.fromPoints(
                              button.localToGlobal(Offset(0, button.size.height), ancestor: overlay),
                              button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
                            ),
                            Offset.zero & overlay.size,
                          );

                          final activeMode = themeMode;
                          final allModes = [ThemeMode.system, ThemeMode.light, ThemeMode.dark];
                          final items = [
                            activeMode,
                            ...allModes.where((mode) => mode != activeMode),
                          ];

                          final newMode = await showMenu<ThemeMode>(
                            context: context,
                            position: position,
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            items: items.map((mode) {
                              final isSelected = mode == themeMode;
                              final String label = mode == ThemeMode.system
                                  ? l10n.systemDefault
                                  : (mode == ThemeMode.dark ? l10n.darkMode : l10n.lightMode);
                              return PopupMenuItem<ThemeMode>(
                                value: mode,
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 4.h),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        label,
                                        style: context.bodyMedium.copyWith(
                                          color: isSelected ? colorScheme.primary : colorScheme.onSurface,
                                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                        ),
                                      ),
                                      if (isSelected)
                                        Icon(
                                          Icons.check_rounded,
                                          color: colorScheme.primary,
                                          size: 18.sp,
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          );

                          if (newMode != null && context.mounted) {
                            context.read<ThemeCubit>().setThemeMode(newMode);
                          }
                        },
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
        style: context.styleSemiBold22.copyWith(fontSize: 14.sp),
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
              style: context.styleSemiBold22.copyWith(fontSize: 16.sp),
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
          style: context.styleSemiBold22.copyWith(fontSize: 16.sp),
        ),
        content: Text(
          l10n.logoutConfirm,
          style: context.styleRegular14.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.cancel,
              style: context.styleMedium14.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
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
              style: context.styleMedium14.copyWith(
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
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Material(
        color: isSelected
            ? colorScheme.primary.withValues(alpha: 0.08)
            : colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16.r),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.r),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.outlineVariant.withValues(alpha: 0.5),
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: context.styleMedium14.copyWith(
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.onSurface,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
                Container(
                  width: 22.r,
                  height: 22.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.outlineVariant,
                      width: 2,
                    ),
                    color: isSelected
                        ? colorScheme.primary
                        : Colors.transparent,
                  ),
                  child: isSelected
                      ? Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 14.sp,
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
