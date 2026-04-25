import 'package:doctor_appointment/core/utils/app_colors.dart';
import 'package:doctor_appointment/core/utils/app_styles.dart';
import 'package:doctor_appointment/core/utils/go_router.dart';
import 'package:doctor_appointment/features/profile/logic/profile_cubit.dart';
import 'package:doctor_appointment/features/profile/logic/profile_state.dart';
import 'package:doctor_appointment/core/services/shared_preferences_helper.dart';
import 'package:doctor_appointment/features/profile/presentation/widgets/profile_header_widget.dart';
import 'package:doctor_appointment/features/profile/presentation/widgets/profile_menu_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  bool _notificationsEnabled = true;
  String _selectedLanguage = 'English';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Profile',
          style: AppStyles.styleSemiBold22.copyWith(fontSize: 18.sp),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            BlocBuilder<ProfileCubit, ProfileState>(
              builder: (context, state) {
                if (state is ProfileLoading) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.h),
                    child: const Center(child: CircularProgressIndicator()),
                  );
                }
                if (state is ProfileSuccess) {
                  return ProfileHeaderWidget(
                    name: state.profile.fullName,
                    email: state.profile.email,
                  );
                }
                if (state is ProfileFailure) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.h),
                    child: Text(
                      state.message,
                      style: AppStyles.styleRegular14.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  );
                }
                return const ProfileHeaderWidget(
                  name: 'Your Name',
                  email: 'your@email.com',
                );
              },
            ),
            _buildSectionLabel('Account'),
            SizedBox(height: 10.h),
            BlocBuilder<ProfileCubit, ProfileState>(
              builder: (context, state) {
                return ProfileMenuItem(
                  icon: Icons.person_outline_rounded,
                  title: 'Personal Information',
                  subtitle: 'Name, email, phone',
                  onTap: () async {
                    if (state is! ProfileSuccess) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Profile not loaded')),
                      );
                      return;
                    }
                    final updated = await context.push<bool>(
                      AppRouter.kEditProfileView,
                      extra: state.profile,
                    );
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
              title: 'Change Password',
              subtitle: 'Update your password',
              onTap: () {},
            ),
            SizedBox(height: 20.h),
            _buildSectionLabel('Health'),
            SizedBox(height: 10.h),
            ProfileMenuItem(
              icon: Icons.description_outlined,
              title: 'Medical Records',
              subtitle: 'View your health documents',
              onTap: () => context.push(AppRouter.kMedicalRecordsView),
            ),
            SizedBox(height: 10.h),
            ProfileMenuItem(
              icon: Icons.payment_rounded,
              title: 'Payment History',
              subtitle: 'Check past transactions',
              onTap: () => context.push(AppRouter.kPaymentHistoryView),
            ),
            SizedBox(height: 20.h),
            _buildSectionLabel('Preferences'),
            SizedBox(height: 10.h),
            ProfileMenuItem(
              icon: Icons.language_rounded,
              title: 'Language',
              subtitle: _selectedLanguage,
              onTap: () => _showLanguagePicker(context),
            ),
            SizedBox(height: 10.h),
            ProfileMenuItem(
              icon: Icons.notifications_outlined,
              title: 'Notifications',
              subtitle: _notificationsEnabled ? 'Enabled' : 'Disabled',
              trailing: Switch(
                value: _notificationsEnabled,
                onChanged: (v) => setState(() => _notificationsEnabled = v),
                activeThumbColor: AppColors.primary,
              ),
            ),
            SizedBox(height: 20.h),
            _buildSectionLabel('Support'),
            SizedBox(height: 10.h),
            ProfileMenuItem(
              icon: Icons.help_outline_rounded,
              title: 'Help & Support',
              onTap: () {},
            ),
            SizedBox(height: 10.h),
            ProfileMenuItem(
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
              onTap: () {},
            ),
            SizedBox(height: 20.h),
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
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
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
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'Select Language',
              style: AppStyles.styleSemiBold22.copyWith(fontSize: 16.sp),
            ),
            SizedBox(height: 16.h),
            ...['English', 'Arabic', 'French', 'Spanish'].map(
              (lang) => GestureDetector(
                onTap: () {
                  setState(() => _selectedLanguage = lang);
                  Navigator.pop(context);
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(lang, style: AppStyles.styleMedium14),
                      if (_selectedLanguage == lang)
                        Icon(
                          Icons.check_rounded,
                          color: AppColors.primary,
                          size: 18.sp,
                        ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 8.h),
          ],
        ),
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
