import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.height,
    required this.width,
    required this.text,
    required this.onPressed,
    required this.buttonColor,
    required this.textStyle,
    this.circleSize = 12,
    this.borderColor,
  });

  final double height;
  final double width;
  final String text;
  final VoidCallback onPressed;
  final Color buttonColor;
  final TextStyle textStyle;
  final double circleSize;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: buttonColor,
        borderRadius: BorderRadius.circular(circleSize),
        border: borderColor != null
            ? Border.all(color: borderColor!, width: 1.5)
            : null,
      ),
      child: TextButton(
        onPressed: onPressed,
        child: Text(text, style: textStyle),
      ),
    );
  }
}
