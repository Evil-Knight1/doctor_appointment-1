import 'package:doctor_appointment/core/utils/app_styles.dart';
import 'package:doctor_appointment/core/utils/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class DoctorSignUpFooter extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onSubmit;
  final bool isLastStep;

  const DoctorSignUpFooter({
    super.key,
    required this.isLoading,
    required this.onSubmit,
    this.isLastStep = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        _SubmitButton(
          isLoading: isLoading,
          label: isLastStep ? 'Submit Application' : 'Next Step',
          icon: isLastStep ? Icons.send_rounded : Icons.arrow_forward_rounded,
          onPressed: isLoading ? null : onSubmit,
        ),
        SizedBox(height: 24.h),
        Center(
          child: Padding(
            padding: EdgeInsets.only(bottom: 20.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Already have an account? ',
                  style: AppStyles.styleRegular14.copyWith(
                    color: theme.textTheme.bodyMedium?.color,
                  ),
                ),
                GestureDetector(
                  onTap: () => context.go(AppRouter.kLoginView),
                  child: Text(
                    'Login',
                    style: AppStyles.styleMedium14.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({
    required this.isLoading,
    required this.label,
    required this.icon,
    this.onPressed,
  });
  final bool isLoading;
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final secondaryColor = Color.lerp(primaryColor, Colors.black, 0.2) ?? primaryColor;

    return Container(
      width: double.infinity,
      height: 54.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        gradient: LinearGradient(
          colors: onPressed == null
              ? [primaryColor.withValues(alpha: 0.6), secondaryColor.withValues(alpha: 0.6)]
              : [primaryColor, secondaryColor],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: onPressed == null
            ? []
            : [
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? SizedBox(
                width: 22.w,
                height: 22.h,
                child: const CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 20.sp),
                  SizedBox(width: 10.w),
                  Text(
                    label,
                    style: AppStyles.styleSemiBold16.copyWith(
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

