import 'package:doctor_appointment/core/utils/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomTextFormField extends StatefulWidget {
  const CustomTextFormField({
    super.key,
    required this.hintText,
    this.textInputType = TextInputType.text,
    this.suffixIcon,
    this.onSaved,
    this.controller,
    this.obscureText = false,
    this.isPassword = false,
    this.focusNode,
    this.maxLines = 1,
  });

  final String hintText;
  final TextInputType textInputType;
  final Widget? suffixIcon;
  final void Function(String?)? onSaved;
  final TextEditingController? controller;
  final bool obscureText;
  final bool isPassword;
  final FocusNode? focusNode;
  final int? maxLines;

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: widget.isPassword ? _obscureText : widget.obscureText,
      controller: widget.controller,
      focusNode: widget.focusNode,
      onSaved: widget.onSaved,
      maxLines: widget.maxLines,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'this field is required';
        }
        return null;
      },
      keyboardType: widget.textInputType,
      decoration: InputDecoration(
        suffixIcon: widget.isPassword
            ? IconButton(
                onPressed: () => setState(() => _obscureText = !_obscureText),
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  color: const Color(0xFF949D9E),
                ),
              )
            : widget.suffixIcon,
        hintStyle: AppStyles.styleRegular14.copyWith(
          color: const Color(0xFF949D9E),
        ),
        hintText: widget.hintText,
        filled: true,
        fillColor: Colors.white,
        border: buildBorder(),
        enabledBorder: buildBorder(),
        focusedBorder: buildBorder(),
      ),
    );
  }

  OutlineInputBorder buildBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.r),
      borderSide: const BorderSide(width: 1, color: Color(0xFFDADADA)),
    );
  }
}
