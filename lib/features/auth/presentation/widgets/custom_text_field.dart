import 'package:flutter/material.dart';

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

    /// Server-side validation error to display below the field.
    /// When set, it overrides the local "required" validation message.
    this.serverError,
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
  final String? serverError;

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
        // Show the server error message if provided
        if (widget.serverError != null && widget.serverError!.isNotEmpty) {
          return widget.serverError;
        }
        if (value == null || value.isEmpty) {
          return 'This field is required';
        }
        return null;
      },
      autovalidateMode: widget.serverError != null
          ? AutovalidateMode.always
          : AutovalidateMode.disabled,
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
        hintText: widget.hintText,
        errorText: null, // handled via validator
      ),
    );
  }

}
