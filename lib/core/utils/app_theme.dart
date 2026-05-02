import 'package:doctor_appointment/core/utils/app_colors.dart';
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorSchemeSeed: AppColors.primary,
    scaffoldBackgroundColor: AppColors.bg,
    fontFamily: 'Inter',
    textTheme: _textTheme(Brightness.light),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.bg,
      elevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(color: AppColors.textSecondary),
    ),
    inputDecorationTheme: _inputDecorationTheme(Brightness.light),
  );

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorSchemeSeed: AppColors.primary,
    scaffoldBackgroundColor: AppColors.darkBg,
    fontFamily: 'Inter',
    textTheme: _textTheme(Brightness.dark),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkBg,
      elevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(color: AppColors.textLight),
    ),
    inputDecorationTheme: _inputDecorationTheme(Brightness.dark),
  );

  static TextTheme _textTheme(Brightness brightness) {
    final color = brightness == Brightness.light ? AppColors.textPrimary : AppColors.darkTextPrimary;
    final secondaryColor = brightness == Brightness.light ? AppColors.textSecondary : AppColors.darkTextSecondary;

    return TextTheme(
      displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primary),
      headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
      headlineMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: color),
      titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: color),
      titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: color),
      titleSmall: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: color),
      bodyLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: color),
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: secondaryColor),
      bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: secondaryColor),
      labelSmall: TextStyle(fontSize: 10, fontWeight: FontWeight.normal, color: secondaryColor),
    );
  }

  static InputDecorationTheme _inputDecorationTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final fillColor = isDark ? AppColors.darkSurface : AppColors.gray100;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.gray200;
    final hintColor = isDark ? AppColors.darkTextSecondary : AppColors.textLight;

    return InputDecorationTheme(
      filled: true,
      fillColor: fillColor,
      hintStyle: TextStyle(color: hintColor, fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: _buildBorder(borderColor),
      enabledBorder: _buildBorder(borderColor),
      focusedBorder: _buildBorder(AppColors.primary, width: 1.5),
      errorBorder: _buildBorder(AppColors.accent),
      focusedErrorBorder: _buildBorder(AppColors.accent, width: 1.5),
    );
  }

  static OutlineInputBorder _buildBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
