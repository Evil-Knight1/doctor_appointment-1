import 'package:doctor_appointment/core/utils/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A styled dropdown field for registration forms.
/// Supports required indicators, prefix icons, and custom item lists.
class RegistrationDropdown<T> extends StatefulWidget {
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
  State<RegistrationDropdown<T>> createState() => _RegistrationDropdownState<T>();
}

class _RegistrationDropdownState<T> extends State<RegistrationDropdown<T>> {
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
          child: DropdownButtonFormField<T>(
            initialValue: widget.value,
            items: widget.items,
            onChanged: widget.onChanged,
            isExpanded: true,
            focusNode: _focusNode,
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: _isFocused ? theme.colorScheme.primary : theme.hintColor,
              size: 22.sp,
            ),
            dropdownColor: theme.cardColor,
            style: AppStyles.styleMedium14.copyWith(
              color: theme.textTheme.headlineLarge?.color,
            ),
            validator: widget.validator ?? (value) {
              if (widget.isRequired && value == null) {
                return '${widget.label} is required';
              }
              return null;
            },
            decoration: InputDecoration(
              hintText: widget.hintText,
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
            ),
          ),
        ),
      ],
    );
  }
}
