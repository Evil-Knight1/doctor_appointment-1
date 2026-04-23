import 'package:doctor_appointment/core/utils/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A styled dropdown field for registration forms.
/// Supports required indicators, prefix icons, and custom item lists.
class RegistrationDropdown<T> extends StatelessWidget {
  const RegistrationDropdown({
    super.key,
    required this.label,
    required this.hintText,
    required this.items,
    required this.onChanged,
    this.value,
    this.isRequired = true,
    this.prefixIcon,
    this.validator,
  });

  final String label;
  final String hintText;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?) onChanged;
  final T? value;
  final bool isRequired;
  final IconData? prefixIcon;
  final String? Function(T?)? validator;

  @override
  Widget build(BuildContext context) {
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
        DropdownButtonFormField<T>(
          initialValue: value,
          items: items,
          onChanged: onChanged,
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: const Color(0xFF949D9E),
            size: 22.sp,
          ),
          dropdownColor: Colors.white,
          style: AppStyles.styleMedium14.copyWith(
            color: const Color(0xff1E252D),
          ),
          validator: validator ??
              (value) {
                if (isRequired && value == null) {
                  return '$label is required';
                }
                return null;
              },
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: AppStyles.styleRegular14.copyWith(
              color: const Color(0xFF949D9E),
            ),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            prefixIcon: prefixIcon != null
                ? Padding(
                    padding: EdgeInsets.only(left: 14.w, right: 10.w),
                    child: Icon(
                      prefixIcon,
                      size: 20.sp,
                      color: const Color(0xFF949D9E),
                    ),
                  )
                : null,
            prefixIconConstraints: prefixIcon != null
                ? BoxConstraints(minWidth: 44.w, minHeight: 20.h)
                : null,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 14.h,
            ),
            border: _buildBorder(const Color(0xFFE2E8F0)),
            enabledBorder: _buildBorder(const Color(0xFFE2E8F0)),
            focusedBorder: _buildBorder(const Color(0xff236DEC), width: 1.5),
            errorBorder: _buildBorder(const Color(0xFFEF4444)),
            focusedErrorBorder:
                _buildBorder(const Color(0xFFEF4444), width: 1.5),
            errorStyle: AppStyles.styleRegular12.copyWith(
              color: const Color(0xFFEF4444),
            ),
          ),
        ),
      ],
    );
  }

  OutlineInputBorder _buildBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.r),
      borderSide: BorderSide(width: width, color: color),
    );
  }
}
