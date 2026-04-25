import 'package:doctor_appointment/core/utils/app_colors.dart';
import 'package:doctor_appointment/core/utils/app_styles.dart';
import 'package:doctor_appointment/features/appointment/data/models/slot_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
    if (slots.isEmpty) {
      return Text(
        'No available slots for this date.',
        style: AppStyles.styleMedium14.copyWith(color: AppColors.textSecondary),
      );
    }
    
    return Wrap(
      spacing: 10.w,
      runSpacing: 10.h,
      children: slots.map((slot) {
        final isSelected = selectedSlot?.id == slot.id;
        final timeString = '${slot.startTime.hour.toString().padLeft(2, '0')}:${slot.startTime.minute.toString().padLeft(2, '0')}';
        
        return GestureDetector(
          onTap: () => onSlotSelected(slot),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : AppColors.bg,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
              ),
            ),
            child: Text(
              timeString,
              style: AppStyles.styleRegular12.copyWith(
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
