import 'package:doctor_appointment/core/utils/app_styles.dart';
import 'package:doctor_appointment/core/utils/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class PatientSignUpFooter extends StatelessWidget {
  final bool isLoading;
  final String label;
  final VoidCallback? onPressed;

  const PatientSignUpFooter({
    super.key,
    required this.isLoading,
    required this.label,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _SubmitButton(
          isLoading: isLoading,
          label: label,
          onPressed: onPressed,
        ),
        SizedBox(height: 24.h),
        Center(
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
      ],
    );
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({
    required this.isLoading,
    required this.label,
    this.onPressed,
  });
  final bool isLoading;
  final String label;
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
              ? [
                  primaryColor.withValues(alpha: 0.6),
                  secondaryColor.withValues(alpha: 0.6)
                ]
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
                  Icon(
                    label == 'Continue'
                        ? Icons.arrow_forward_rounded
                        : Icons.send_rounded,
                    size: 20.sp,
                  ),
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

