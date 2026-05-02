import 'package:doctor_appointment/core/utils/app_styles.dart';
import 'package:doctor_appointment/core/utils/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class UserSelectionView extends StatelessWidget {
  const UserSelectionView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary.withValues(alpha: 0.05),
              theme.scaffoldBackgroundColor,
              theme.scaffoldBackgroundColor,
            ],
            stops: const [0.0, 0.3, 1.0],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 40.h),

                // Premium Logo Branding
                Hero(
                  tag: 'app_logo',
                  child: Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withValues(alpha: 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.health_and_safety_rounded,
                      color: theme.colorScheme.primary,
                      size: 48.sp,
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  'MedLink+',
                  style: AppStyles.styleBold24.copyWith(
                    color: theme.colorScheme.primary,
                    letterSpacing: -0.5,
                  ),
                ),
                
                SizedBox(height: 48.h),

                // Welcome Text
                Text(
                  'Choose Your Role',
                  style: AppStyles.styleBold32.copyWith(
                    fontSize: 28.sp,
                    color: theme.textTheme.headlineLarge?.color,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  'Are you looking for medical care or\noffering professional services?',
                  style: AppStyles.styleRegular14.copyWith(
                    color: theme.textTheme.bodyMedium?.color,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 48.h),

                // Role Selection Cards
                Row(
                  children: [
                    Expanded(
                      child: _RoleCard(
                        icon: Icons.person_outline_rounded,
                        activeIcon: Icons.person_rounded,
                        title: "Patient",
                        description: 'Book and manage\nappointments',
                        isSelected: false,
                        onTap: () => context.push(AppRouter.kSignUpView),
                      ),
                    ),
                    SizedBox(width: 20.w),
                    Expanded(
                      child: _RoleCard(
                        icon: Icons.medical_services_outlined,
                        activeIcon: Icons.medical_services_rounded,
                        title: "Doctor",
                        description: 'Manage clinic and\npatient requests',
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
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 24.w),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already a member? ',
                          style: AppStyles.styleRegular14.copyWith(
                            color: theme.textTheme.bodyMedium?.color,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.push(AppRouter.kLoginView),
                          child: Text(
                            'Sign In',
                            style: AppStyles.styleSemiBold16.copyWith(
                              color: theme.colorScheme.primary,
                              fontSize: 14.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
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

class _RoleCard extends StatefulWidget {
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
  State<_RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<_RoleCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool active = widget.isSelected || _isHovered;
    
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _isHovered = true),
      onTapUp: (_) => setState(() => _isHovered = false),
      onTapCancel: () => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: active ? 1.02 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: EdgeInsets.symmetric(vertical: 32.h, horizontal: 16.w),
          decoration: BoxDecoration(
            color: active ? theme.colorScheme.primary : theme.cardColor,
            borderRadius: BorderRadius.circular(28.r),
            gradient: active ? LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.primary.withValues(alpha: 0.8),
              ],
            ) : null,
            border: Border.all(
              color: active ? theme.colorScheme.primary : theme.dividerColor,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: active 
                    ? theme.colorScheme.primary.withValues(alpha: 0.25) 
                    : theme.shadowColor.withValues(alpha: 0.05),
                blurRadius: active ? 24 : 12,
                offset: Offset(0, active ? 12 : 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: active 
                      ? theme.colorScheme.onPrimary.withValues(alpha: 0.2) 
                      : theme.colorScheme.primary.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  active ? widget.activeIcon : widget.icon,
                  size: 36.sp,
                  color: active ? theme.colorScheme.onPrimary : theme.colorScheme.primary,
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                widget.title,
                style: AppStyles.styleBold32.copyWith(
                  fontSize: 20.sp,
                  color: active ? theme.colorScheme.onPrimary : theme.textTheme.headlineLarge?.color,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                widget.description,
                textAlign: TextAlign.center,
                style: AppStyles.styleRegular12.copyWith(
                  fontSize: 12.sp,
                  color: active 
                      ? theme.colorScheme.onPrimary.withValues(alpha: 0.9) 
                      : theme.textTheme.bodyMedium?.color,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
