import 'package:doctor_appointment/core/theme/app_theme_extension.dart';
import 'package:doctor_appointment/core/utils/app_colors.dart';
import 'package:flex_seed_scheme/flex_seed_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppTheme {
  static ThemeData get theme => _buildTheme(Brightness.light);
  static ThemeData get darkTheme => _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final isLight = brightness == Brightness.light;

    // Create a color scheme from seeds using flex_seed_scheme
    final colorScheme = SeedColorScheme.fromSeeds(
      brightness: brightness,
      primaryKey: AppColors.primary,
      secondaryKey: AppColors.secondary,
      tertiaryKey: AppColors.accent,
      surfaceTint: isLight ? AppColors.primary : Colors.transparent,
      // Use predefined tones for a balanced look
      tones: isLight ? FlexTones.soft(brightness) : FlexTones.vivid(brightness),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: isLight ? AppColors.bg : AppColors.darkBg,
      cardColor: isLight ? AppColors.white : AppColors.darkSurface,
      dividerColor: isLight ? AppColors.gray200 : AppColors.darkBorder,
      hintColor: isLight
          ? AppColors.textSecondary
          : AppColors.darkTextSecondary,
      shadowColor: isLight
          ? Colors.black.withValues(alpha: 0.05)
          : Colors.black.withValues(alpha: 0.2),
      canvasColor: isLight ? AppColors.bg : AppColors.darkBg,
      fontFamily: 'Inter',
      textTheme: _textTheme(brightness, colorScheme),
      appBarTheme: AppBarTheme(
        backgroundColor: isLight ? AppColors.bg : AppColors.darkBg,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: _textTheme(brightness, colorScheme).titleLarge
            ?.copyWith(
              fontWeight: FontWeight.bold,
              color: isLight
                  ? AppColors.textPrimary
                  : AppColors.darkTextPrimary,
            ),
        iconTheme: IconThemeData(
          color: isLight ? AppColors.textPrimary : AppColors.darkTextPrimary,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      cardTheme: CardThemeData(
        color: isLight ? AppColors.white : AppColors.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isLight ? AppColors.gray200 : AppColors.darkBorder,
          ),
        ),
      ),
      inputDecorationTheme: _inputDecorationTheme(brightness),
      iconTheme: IconThemeData(
        color: isLight ? AppColors.textSecondary : AppColors.darkTextSecondary,
      ),
      extensions: [
        AppCustomColors(
          success: AppColors.success,
          warning: AppColors.warning,
          appointmentPending: AppColors.pending,
          doctorOnline: AppColors.online,
          offline: AppColors.offline,
          chatBubbleMine: isLight ? AppColors.primary : AppColors.primary,
          chatBubbleOthers: isLight ? AppColors.gray100 : AppColors.darkSurface,
          chatBubbleMineGradientStart: AppColors.headerGradientStart,
          chatBubbleMineGradientEnd: AppColors.headerGradientEnd,
          rating: AppColors.star,
          error: AppColors.error,
        ),
      ],
    );
  }

  static TextTheme _textTheme(Brightness brightness, ColorScheme colorScheme) {
    final isLight = brightness == Brightness.light;
    final primaryColor = isLight
        ? AppColors.textPrimary
        : AppColors.darkTextPrimary;
    final secondaryColor = isLight
        ? AppColors.textSecondary
        : AppColors.darkTextSecondary;
    final lightColor = isLight ? AppColors.textLight : AppColors.darkTextLight;

    return TextTheme(
      displayLarge: TextStyle(
        fontSize: 32.sp,
        fontWeight: FontWeight.bold,
        color: primaryColor,
        fontFamily: 'Inter',
      ),
      displayMedium: TextStyle(
        fontSize: 28.sp,
        fontWeight: FontWeight.bold,
        color: primaryColor,
        fontFamily: 'Inter',
      ),
      displaySmall: TextStyle(
        fontSize: 24.sp,
        fontWeight: FontWeight.bold,
        color: primaryColor,
        fontFamily: 'Inter',
      ),
      headlineLarge: TextStyle(
        fontSize: 24.sp,
        fontWeight: FontWeight.bold,
        color: primaryColor,
        fontFamily: 'Inter',
      ),
      headlineMedium: TextStyle(
        fontSize: 22.sp,
        fontWeight: FontWeight.w600,
        color: primaryColor,
        fontFamily: 'Inter',
      ),
      headlineSmall: TextStyle(
        fontSize: 20.sp,
        fontWeight: FontWeight.w600,
        color: primaryColor,
        fontFamily: 'Inter',
      ),
      titleLarge: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.w700,
        color: primaryColor,
        fontFamily: 'Inter',
      ),
      titleMedium: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        color: primaryColor,
        fontFamily: 'Inter',
      ),
      titleSmall: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: primaryColor,
        fontFamily: 'Inter',
      ),
      bodyLarge: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w400,
        color: primaryColor,
        fontFamily: 'Inter',
      ),
      bodyMedium: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
        color: secondaryColor,
        fontFamily: 'Inter',
      ),
      bodySmall: TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w400,
        color: secondaryColor,
        fontFamily: 'Inter',
      ),
      labelLarge: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: primaryColor,
        fontFamily: 'Inter',
      ),
      labelMedium: TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
        color: secondaryColor,
        fontFamily: 'Inter',
      ),
      labelSmall: TextStyle(
        fontSize: 10.sp,
        fontWeight: FontWeight.w400,
        color: lightColor,
        fontFamily: 'Inter',
      ),
    );
  }

  static InputDecorationTheme _inputDecorationTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final fillColor = isDark ? AppColors.darkSurface : AppColors.gray100;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.gray200;
    final hintColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.textLight;

    return InputDecorationTheme(
      filled: true,
      fillColor: fillColor,
      hintStyle: TextStyle(color: hintColor, fontSize: 14),
      labelStyle: TextStyle(
        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
        fontSize: 14,
      ),
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
