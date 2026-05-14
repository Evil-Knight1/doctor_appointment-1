import 'package:doctor_appointment/core/theme/app_theme_extension.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class DatePickerWidget extends StatelessWidget {
  final DateTime selectedDate;
  final List<DateTime> weekDays;
  final ValueChanged<DateTime> onDateSelected;

  /// Dates that have at least one available slot — shown with a dot indicator.
  final Set<DateTime> availableDates;

  const DatePickerWidget({
    super.key,
    required this.selectedDate,
    required this.weekDays,
    required this.onDateSelected,
    this.availableDates = const {},
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => _selectDate(context),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      DateFormat('MMMM, yyyy').format(selectedDate),
                      style: context.styleSemiBold16.copyWith(
                        fontSize: 14.sp,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: colorScheme.onPrimaryContainer,
                      size: 18.sp,
                    ),
                  ],
                ),
              ),
            ),
            Text(
              'Today',
              style: context.styleMedium14.copyWith(
                color: colorScheme.primary,
                fontSize: 13.sp,
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        SizedBox(
          height: 84.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: weekDays.length,
            physics: const BouncingScrollPhysics(),
            separatorBuilder: (context, index) => SizedBox(width: 12.w),
            itemBuilder: (context, index) {
              final date = weekDays[index];
              final isSelected = DateUtils.isSameDay(date, selectedDate);
              final hasSlots = availableDates.any(
                (d) => DateUtils.isSameDay(d, date),
              );
              return _DateItem(
                date: date,
                isSelected: isSelected,
                hasSlots: hasSlots,
                onTap: () => onDateSelected(date),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme,
          ),
          child: child!,
        );
      },
    );
    if (date != null) {
      onDateSelected(date);
    }
  }
}

class _DateItem extends StatelessWidget {
  final DateTime date;
  final bool isSelected;
  final bool hasSlots;
  final VoidCallback onTap;

  const _DateItem({
    required this.date,
    required this.isSelected,
    required this.onTap,
    this.hasSlots = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 54.w,
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary
              : hasSlots
              ? colorScheme.surface
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : hasSlots
                ? colorScheme.outlineVariant
                : colorScheme.outlineVariant.withValues(alpha: 0.4),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              DateFormat('EEE').format(date),
              style: context.styleMedium14.copyWith(
                fontSize: 12.sp,
                color: isSelected
                    ? colorScheme.onPrimary.withValues(alpha: 0.7)
                    : hasSlots
                    ? colorScheme.onSurfaceVariant
                    : colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              '${date.day}',
              style: context.styleSemiBold18.copyWith(
                fontSize: 18.sp,
                color: isSelected
                    ? colorScheme.onPrimary
                    : hasSlots
                    ? colorScheme.onSurface
                    : colorScheme.onSurface.withValues(alpha: 0.35),
              ),
            ),
            SizedBox(height: 4.h),
            // Dot: white on selected, primary-color on days with slots, invisible otherwise
            Container(
              width: 4.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: isSelected
                    ? colorScheme.onPrimary
                    : hasSlots
                    ? colorScheme.primary
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

