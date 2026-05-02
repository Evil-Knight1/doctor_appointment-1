import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StepProgressIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const StepProgressIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      children: List.generate(totalSteps, (index) {
        final isActive = index <= currentStep;
        final isCurrent = index == currentStep;
        
        return Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutCubic,
            margin: EdgeInsets.symmetric(horizontal: 4.w),
            height: isCurrent ? 8.h : 6.h,
            decoration: BoxDecoration(
              color: isActive ? theme.colorScheme.primary : theme.dividerColor,
              borderRadius: BorderRadius.circular(10.r),
              boxShadow: isCurrent ? [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ] : null,
            ),
          ),
        );
      }),
    );
  }
}

