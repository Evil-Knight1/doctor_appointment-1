import 'package:doctor_appointment/core/utils/app_styles.dart';
import 'package:doctor_appointment/features/appointment/data/models/slot_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class AvailableTimeWidget extends StatelessWidget {
  final List<SlotModel> slots;
  final SlotModel? selectedSlot;
  final ValueChanged<SlotModel> onSlotSelected;

  const AvailableTimeWidget({
    super.key,
    required this.slots,
    this.selectedSlot,
    required this.onSlotSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    // Only show slots that are available and not yet booked
    final availableSlots =
        slots.where((s) => s.isAvailable && !s.isBooked).toList();

    if (availableSlots.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20.h),
          child: Column(
            children: [
              Icon(
                Icons.event_busy_rounded,
                size: 48.sp,
                color: colorScheme.outlineVariant,
              ),
              SizedBox(height: 12.h),
              Text(
                'No available slots for this date.',
                style: AppStyles.styleMedium14.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final morningSlots =
        availableSlots.where((s) => s.startTime.hour < 12).toList();
    final afternoonSlots = availableSlots
        .where((s) => s.startTime.hour >= 12 && s.startTime.hour < 17)
        .toList();
    final eveningSlots =
        availableSlots.where((s) => s.startTime.hour >= 17).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (morningSlots.isNotEmpty) ...[
          _buildTimeSection(
            context,
            'Morning',
            Icons.wb_sunny_outlined,
            morningSlots,
          ),
          SizedBox(height: 20.h),
        ],
        if (afternoonSlots.isNotEmpty) ...[
          _buildTimeSection(
            context,
            'Afternoon',
            Icons.light_mode_outlined,
            afternoonSlots,
          ),
          SizedBox(height: 20.h),
        ],
        if (eveningSlots.isNotEmpty) ...[
          _buildTimeSection(
            context,
            'Evening',
            Icons.dark_mode_outlined,
            eveningSlots,
          ),
        ],
      ],
    );
  }

  Widget _buildTimeSection(
    BuildContext context,
    String title,
    IconData icon,
    List<SlotModel> sectionSlots,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16.sp, color: colorScheme.onSurfaceVariant),
            SizedBox(width: 6.w),
            Text(
              title,
              style: AppStyles.styleMedium14.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontSize: 13.sp,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 12.w,
          runSpacing: 12.h,
          children: sectionSlots
              .map((slot) => _buildTimeChip(context, slot))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildTimeChip(BuildContext context, SlotModel slot) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected = selectedSlot?.id == slot.id;
    final timeString = DateFormat('hh:mm a').format(slot.startTime);

    return GestureDetector(
      onTap: () => onSlotSelected(slot),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary : colorScheme.surface,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: isSelected ? colorScheme.primary : colorScheme.outlineVariant,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Text(
          timeString,
          style: AppStyles.styleMedium14.copyWith(
            fontSize: 13.sp,
            color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}

