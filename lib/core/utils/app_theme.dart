import 'package:doctor_appointment/core/utils/app_colors.dart';
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      secondary: AppColors.primaryLight,
      surface: AppColors.bg,
      onSurface: AppColors.textPrimary,
      error: AppColors.accent,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: AppColors.bg,
    cardColor: AppColors.white,
    dividerColor: AppColors.gray200,
    hintColor: AppColors.textSecondary,
    shadowColor: AppColors.black.withValues(alpha: 0.05),
    canvasColor: AppColors.bg,
    fontFamily: 'Inter',
    textTheme: _textTheme(Brightness.light),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.bg,
      elevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(color: AppColors.textPrimary),
    ),
    inputDecorationTheme: _inputDecorationTheme(Brightness.light),
    iconTheme: const IconThemeData(color: AppColors.textSecondary),
  );

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      secondary: AppColors.darkSurface,
      surface: AppColors.darkBg,
      onSurface: AppColors.darkTextPrimary,
      error: AppColors.accent,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: AppColors.darkBg,
    cardColor: AppColors.darkSurface,
    dividerColor: AppColors.darkBorder,
    hintColor: AppColors.darkTextSecondary,
    shadowColor: Colors.black.withValues(alpha: 0.2),
    canvasColor: AppColors.darkBg,
    fontFamily: 'Inter',
    textTheme: _textTheme(Brightness.dark),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkBg,
      elevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(color: AppColors.darkTextPrimary),
    ),
    inputDecorationTheme: _inputDecorationTheme(Brightness.dark),
    iconTheme: const IconThemeData(color: AppColors.darkTextSecondary),
  );

  static TextTheme _textTheme(Brightness brightness) {
    final isLight = brightness == Brightness.light;
    final primaryColor = isLight ? AppColors.textPrimary : AppColors.darkTextPrimary;
    final secondaryColor = isLight ? AppColors.textSecondary : AppColors.darkTextSecondary;
    final lightColor = isLight ? AppColors.textLight : AppColors.darkTextLight;

    return TextTheme(
      displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primary),
      displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: primaryColor),
      displaySmall: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primaryColor),
      headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primaryColor),
      headlineMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: primaryColor),
      headlineSmall: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: primaryColor),
      titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: primaryColor),
      titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: primaryColor),
      titleSmall: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: primaryColor),
      bodyLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: primaryColor),
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: secondaryColor),
      bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: secondaryColor),
      labelLarge: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: primaryColor),
      labelMedium: TextStyle(fontSize: 11, fontWeight: FontWeight.normal, color: secondaryColor),
      labelSmall: TextStyle(fontSize: 10, fontWeight: FontWeight.normal, color: lightColor),
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
      labelStyle: TextStyle(color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary, fontSize: 14),
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
