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
    this.serverError,
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
  final String? serverError;

  @override
  State<RegistrationTextField> createState() => _RegistrationTextFieldState();
}

class _RegistrationTextFieldState extends State<RegistrationTextField> {
  bool _obscureText = true;
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    } else {
      _focusNode.removeListener(_onFocusChange);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
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
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: TextFormField(
            controller: widget.controller,
            keyboardType: widget.keyboardType,
            obscureText: widget.isPassword ? _obscureText : false,
            maxLines: widget.isPassword ? 1 : widget.maxLines,
            inputFormatters: widget.inputFormatters,
            textInputAction: widget.textInputAction,
            focusNode: _focusNode,
            onFieldSubmitted: widget.onFieldSubmitted,
            style: AppStyles.styleMedium14.copyWith(
              color: theme.textTheme.headlineLarge?.color,
            ),
            validator: widget.validator ?? (value) {
              if (widget.isRequired && (value == null || value.trim().isEmpty)) {
                return '${widget.label} is required';
              }
              return null;
            },
            decoration: InputDecoration(
              hintText: widget.hintText,
              errorText: widget.serverError,
              prefixIcon: widget.prefixIcon != null
                  ? AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: EdgeInsets.only(left: 14.w, right: 10.w),
                      child: Icon(
                        widget.prefixIcon,
                        size: 20.sp,
                        color: _isFocused
                            ? theme.colorScheme.primary
                            : theme.hintColor,
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
                      onPressed: () => setState(() => _obscureText = !_obscureText),
                      icon: Icon(
                        _obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: _isFocused ? theme.colorScheme.primary : theme.hintColor,
                        size: 20.sp,
                      ),
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}
