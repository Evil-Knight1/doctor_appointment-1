import 'package:doctor_appointment/core/utils/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A tappable date picker field styled consistently with other registration
/// form fields. Shows a modal date picker and formats the selected date.
class RegistrationDatePicker extends StatelessWidget {
  const RegistrationDatePicker({
    super.key,
    required this.label,
    required this.hintText,
    required this.onDateSelected,
    this.selectedDate,
    this.isRequired = false,
    this.prefixIcon,
    this.firstDate,
    this.lastDate,
  });

  final String label;
  final String hintText;
  final void Function(DateTime) onDateSelected;
  final DateTime? selectedDate;
  final bool isRequired;
  final IconData? prefixIcon;
  final DateTime? firstDate;
  final DateTime? lastDate;

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  String _formatDate(DateTime date) {
    return '${_months[date.month - 1]} ${date.day.toString().padLeft(2, '0')}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final displayText =
        selectedDate != null ? _formatDate(selectedDate!) : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: AppStyles.styleMedium14,
            children: [
              if (isRequired)
                TextSpan(
                  text: ' *',
                  style: AppStyles.styleMedium14.copyWith(
                    color: const Color(0xFFEF4444),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: () => _pickDate(context),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 14.h,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: const Color(0xFFE2E8F0),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                if (prefixIcon != null) ...[
                  Icon(
                    prefixIcon,
                    size: 20.sp,
                    color: const Color(0xFF949D9E),
                  ),
                  SizedBox(width: 10.w),
                ],
                Expanded(
                  child: Text(
                    displayText ?? hintText,
                    style: displayText != null
                        ? AppStyles.styleMedium14.copyWith(
                            color: const Color(0xff1E252D),
                          )
                        : AppStyles.styleRegular14.copyWith(
                            color: const Color(0xFF949D9E),
                          ),
                  ),
                ),
                Icon(
                  Icons.calendar_today_outlined,
                  size: 18.sp,
                  color: const Color(0xFF949D9E),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime(now.year - 25),
      firstDate: firstDate ?? DateTime(1920),
      lastDate: lastDate ?? now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xff236DEC),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xff1E252D),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      onDateSelected(picked);
    }
  }
}
