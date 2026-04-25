import 'package:doctor_appointment/core/utils/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A polished, reusable text form field for the registration screens.
/// Supports prefix icons, password toggle, custom validators, max lines, and
/// input formatters — all styled to match the app design system.
class RegistrationTextField extends StatefulWidget {
  const RegistrationTextField({
    super.key,
    required this.label,
    required this.hintText,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.isPassword = false,
    this.isRequired = true,
    this.prefixIcon,
    this.validator,
    this.maxLines = 1,
    this.inputFormatters,
    this.textInputAction = TextInputAction.next,
    this.focusNode,
    this.suffixIcon,
    this.onFieldSubmitted,
  });

  final String label;
  final String hintText;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool isPassword;
  final bool isRequired;
  final IconData? prefixIcon;
  final String? Function(String?)? validator;
  final int maxLines;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction textInputAction;
  final FocusNode? focusNode;
  final Widget? suffixIcon;
  final void Function(String)? onFieldSubmitted;

  @override
  State<RegistrationTextField> createState() => _RegistrationTextFieldState();
}

class _RegistrationTextFieldState extends State<RegistrationTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: widget.label,
            style: AppStyles.styleMedium14,
            children: [
              if (widget.isRequired)
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
        TextFormField(
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          obscureText: widget.isPassword ? _obscureText : false,
          maxLines: widget.isPassword ? 1 : widget.maxLines,
          inputFormatters: widget.inputFormatters,
          textInputAction: widget.textInputAction,
          focusNode: widget.focusNode,
          onFieldSubmitted: widget.onFieldSubmitted,
          style: AppStyles.styleMedium14.copyWith(
            color: const Color(0xff1E252D),
          ),
          validator:
              widget.validator ??
              (value) {
                if (widget.isRequired &&
                    (value == null || value.trim().isEmpty)) {
                  return '${widget.label} is required';
                }
                return null;
              },
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: AppStyles.styleRegular14.copyWith(
              color: const Color(0xFF949D9E),
            ),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            prefixIcon: widget.prefixIcon != null
                ? Padding(
                    padding: EdgeInsets.only(left: 14.w, right: 10.w),
                    child: Icon(
                      widget.prefixIcon,
                      size: 20.sp,
                      color: const Color(0xFF949D9E),
                    ),
                  )
                : null,
            prefixIconConstraints: widget.prefixIcon != null
                ? BoxConstraints(minWidth: 44.w, minHeight: 20.h)
                : null,
            suffixIcon: widget.suffixIcon != null
                ? Padding(
                    padding: EdgeInsets.only(right: 14.w),
                    child: widget.suffixIcon,
                  )
                : widget.isPassword
                ? IconButton(
                    onPressed: () =>
                        setState(() => _obscureText = !_obscureText),
                    icon: Icon(
                      _obscureText
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: const Color(0xFF949D9E),
                      size: 20.sp,
                    ),
                  )
                : null,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 14.h,
            ),
            border: _buildBorder(const Color(0xFFE2E8F0)),
            enabledBorder: _buildBorder(const Color(0xFFE2E8F0)),
            focusedBorder: _buildBorder(const Color(0xff236DEC), width: 1.5),
            errorBorder: _buildBorder(const Color(0xFFEF4444)),
            focusedErrorBorder: _buildBorder(
              const Color(0xFFEF4444),
              width: 1.5,
            ),
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
