
import 'package:doctor_appointment/core/utils/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A tappable date picker field styled consistently with other registration
/// form fields. Shows a modal date picker and formats the selected date.
class RegistrationDatePicker extends StatefulWidget {
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

  @override
  State<RegistrationDatePicker> createState() => _RegistrationDatePickerState();
}

class _RegistrationDatePickerState extends State<RegistrationDatePicker> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  String _formatDate(DateTime date) {
    return '${_months[date.month - 1]} ${date.day.toString().padLeft(2, '0')}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayText =
        widget.selectedDate != null ? _formatDate(widget.selectedDate!) : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: widget.label,
            style: AppStyles.styleMedium14.copyWith(
              color: _isFocused 
                  ? theme.colorScheme.primary 
                  : theme.textTheme.headlineLarge?.color,
            ),
            children: [
              if (widget.isRequired)
                TextSpan(
                  text: ' *',
                  style: AppStyles.styleMedium14.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: () {
            _focusNode.requestFocus();
            _pickDate(context);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 14.h,
            ),
            decoration: BoxDecoration(
              color: _isFocused 
                  ? theme.inputDecorationTheme.fillColor?.withValues(alpha: 0.8) 
                  : theme.inputDecorationTheme.fillColor,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: _isFocused 
                    ? theme.colorScheme.primary 
                    : (theme.inputDecorationTheme.enabledBorder?.borderSide.color ?? theme.dividerColor),
                width: _isFocused ? 1.5 : 1,
              ),
              boxShadow: _isFocused
                  ? [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(alpha: 0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: Row(
              children: [
                if (widget.prefixIcon != null) ...[
                  Icon(
                    widget.prefixIcon,
                    size: 20.sp,
                    color: _isFocused
                        ? theme.colorScheme.primary
                        : theme.hintColor,
                  ),
                  SizedBox(width: 10.w),
                ],
                Expanded(
                  child: Text(
                    displayText ?? widget.hintText,
                    style: displayText != null
                        ? AppStyles.styleMedium14.copyWith(
                            color: theme.textTheme.headlineLarge?.color,
                          )
                        : AppStyles.styleRegular14.copyWith(
                            color: theme.hintColor,
                          ),
                  ),
                ),
                Icon(
                  Icons.calendar_today_rounded,
                  size: 18.sp,
                  color: _isFocused
                      ? theme.colorScheme.primary
                      : theme.hintColor,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: widget.selectedDate ?? DateTime(now.year - 25),
      firstDate: widget.firstDate ?? DateTime(1920),
      lastDate: widget.lastDate ?? now,
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.primary,
                textStyle: AppStyles.styleBold14,
              ),
            ),
            dialogTheme: theme.dialogTheme.copyWith(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      widget.onDateSelected(picked);
    }
    // Remove focus when picker closes
    _focusNode.unfocus();
  }
}


