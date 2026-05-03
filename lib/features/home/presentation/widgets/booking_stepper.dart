import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:doctor_appointment/core/utils/app_dimensions.dart';
import 'package:doctor_appointment/core/utils/app_colors.dart';
import 'package:doctor_appointment/core/utils/app_styles.dart';

class BookingStepper extends StatelessWidget {
  const BookingStepper({super.key, required this.currentStep});
  final int currentStep; // 0=Date, 1=Payment, 2=Summary

  static const _labels = ['Date & Time', 'Payment', 'Summary'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: List.generate(_labels.length * 2 - 1, (i) {
          if (i.isOdd) {
            final stepIndex = i ~/ 2;
            final isCompleted = currentStep > stepIndex;
            return Expanded(
              child: Container(
                height: 2.h,
                color: isCompleted ? AppColors.primary : AppColors.divider,
              ),
            );
          }
          final stepIndex = i ~/ 2;
          return _StepBubble(
            index: stepIndex + 1,
            label: _labels[stepIndex],
            state: stepIndex < currentStep
                ? _StepState.completed
                : stepIndex == currentStep
                    ? _StepState.active
                    : _StepState.inactive,
          );
        }),
      ),
    );
  }
}

enum _StepState { active, completed, inactive }

class _StepBubble extends StatelessWidget {
  const _StepBubble({
    required this.index,
    required this.label,
    required this.state,
  });
  final int index;
  final String label;
  final _StepState state;

  @override
  Widget build(BuildContext context) {
    final isActive = state == _StepState.active;
    final isCompleted = state == _StepState.completed;

    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: 32.w,
          height: 32.h,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive || isCompleted
                ? AppColors.primary
                : AppColors.surfaceVariant,
          ),
          child: Center(
            child: isCompleted
                ? Icon(Icons.check_rounded, size: 16.sp, color: Colors.white)
                : Text(
                    '$index',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: isActive ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            fontSize: 10.sp,
            color: isActive || isCompleted
                ? AppColors.primary
                : AppColors.textSecondary,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
