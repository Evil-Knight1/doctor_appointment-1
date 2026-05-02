
import 'package:doctor_appointment/core/utils/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phone_form_field/phone_form_field.dart';

/// A polished, reusable phone form field for the registration screens.
/// Wraps [PhoneFormField] with consistent focus styling and animations.
class RegistrationPhoneField extends StatefulWidget {
  const RegistrationPhoneField({
    super.key,
    required this.label,
    this.controller,
    this.focusNode,
    this.serverError,
    this.isRequired = true,
  });

  final String label;
  final PhoneController? controller;
  final FocusNode? focusNode;
  final String? serverError;
  final bool isRequired;

  @override
  State<RegistrationPhoneField> createState() => _RegistrationPhoneFieldState();
}

class _RegistrationPhoneFieldState extends State<RegistrationPhoneField> {
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
          child: PhoneFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            style: AppStyles.styleMedium14.copyWith(
              color: theme.textTheme.headlineLarge?.color,
            ),
            decoration: InputDecoration(
              hintText: '1234567890',
              errorText: widget.serverError,
            ),
          ),
        ),
      ],
    );
  }
}

