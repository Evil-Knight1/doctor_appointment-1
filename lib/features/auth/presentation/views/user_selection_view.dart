import 'package:doctor_appointment/core/utils/app_colors.dart';
import 'package:doctor_appointment/core/utils/app_styles.dart';
import 'package:doctor_appointment/core/utils/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class UserSelectionView extends StatelessWidget {
  const UserSelectionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          image: DecorationImage(
            image: const AssetImage('assets/images/auth_bg.png'), // Fallback if exists, otherwise gradient
            fit: BoxFit.cover,
            opacity: 0.05,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 60.h),

                // Logo / App Name
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        Icons.health_and_safety_rounded,
                        color: AppColors.primary,
                        size: 32.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      'MedLink+',
                      style: AppStyles.styleBold32.copyWith(
                        fontSize: 24.sp,
                        color: AppColors.primary,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 48.h),

                // Welcome Text
                Text(
                  'Join Our Medical\nCommunity',
                  style: AppStyles.styleBold32.copyWith(
                    fontSize: 28.sp,
                    height: 1.2,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.h),
                Text(
                  'To provide you with the best experience,\nplease select your role below.',
                  style: AppStyles.styleRegular14.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 56.h),

                // Role Selection Cards
                Row(
                  children: [
                    Expanded(
                      child: _RoleCard(
                        icon: Icons.person_outline_rounded,
                        activeIcon: Icons.person_rounded,
                        title: "Patient",
                        description: 'I want to book\nappointments',
                        isSelected: false, // Could be handled by state if needed
                        onTap: () => context.push(AppRouter.kSignUpView),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: _RoleCard(
                        icon: Icons.medical_services_outlined,
                        activeIcon: Icons.medical_services_rounded,
                        title: "Doctor",
                        description: 'I want to manage\nmy practice',
                        isSelected: false,
                        onTap: () => context.push(AppRouter.kDoctorSignUpView),
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // Login Link
                Padding(
                  padding: EdgeInsets.only(bottom: 24.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: AppStyles.styleRegular14.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.push(AppRouter.kLoginView),
                        child: Text(
                          'Sign In',
                          style: AppStyles.styleSemiBold16.copyWith(
                            color: AppColors.primary,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String title;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.activeIcon,
    required this.title,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(vertical: 32.h, horizontal: 16.w),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border.withValues(alpha: 0.5),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected 
                  ? AppColors.primary.withValues(alpha: 0.25) 
                  : Colors.black.withValues(alpha: 0.03),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: isSelected 
                    ? Colors.white.withValues(alpha: 0.2) 
                    : AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSelected ? activeIcon : icon,
                size: 32.sp,
                color: isSelected ? Colors.white : AppColors.primary,
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              title,
              style: AppStyles.styleBold32.copyWith(
                fontSize: 18.sp,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              description,
              textAlign: TextAlign.center,
              style: AppStyles.styleRegular12.copyWith(
                fontSize: 11.sp,
                color: isSelected 
                    ? Colors.white.withValues(alpha: 0.8) 
                    : AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
