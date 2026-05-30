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
      errorKey: AppColors.error,
      // neutralKey: isLight ? AppColors.bg : AppColors.darkBg,
      surfaceTint: Colors.transparent,

      // Use vivid tones to preserve the saturation of the primary brand color
      tones: FlexTones.vivid(brightness),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      cardColor: colorScheme.surfaceContainerLow,
      dividerColor: colorScheme.outlineVariant,
      hintColor: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
      shadowColor: isLight
          ? Colors.black.withValues(alpha: 0.05)
          : Colors.black.withValues(alpha: 0.2),
      canvasColor: colorScheme.surface,
      fontFamily: 'Inter',
      textTheme: _textTheme(brightness, colorScheme),
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        shadowColor: colorScheme.shadow.withValues(alpha: 0.1),
        centerTitle: false,
        titleTextStyle: _textTheme(brightness, colorScheme).titleLarge
            ?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
        iconTheme: IconThemeData(color: colorScheme.onSurface),
        surfaceTintColor: Colors.transparent,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: colorScheme.primary,
        unselectedLabelColor: colorScheme.onSurfaceVariant,
        indicatorColor: colorScheme.primary,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 14.sp,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12.sp,
        ),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 12.sp,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        constraints: BoxConstraints(maxWidth: 450),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 4,
        highlightElevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isLight
            ? colorScheme.onSurface
            : colorScheme.surfaceContainerHighest,
        contentTextStyle: TextStyle(
          color: isLight ? colorScheme.surface : colorScheme.onSurface,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 24.w),
          textStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 24.w),
          textStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          textStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
        ),
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surfaceContainerLow,
        elevation: isLight ? 0 : 2,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: colorScheme.outlineVariant,
            width: isLight ? 1 : 0.5,
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surface,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titleTextStyle: _textTheme(brightness, colorScheme).headlineSmall,
        contentTextStyle: _textTheme(brightness, colorScheme).bodyMedium,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
        circularTrackColor: colorScheme.primary.withValues(alpha: 0.1),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: colorScheme.onSurface.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: TextStyle(color: colorScheme.surface, fontSize: 12.sp),
      ),
      inputDecorationTheme: _inputDecorationTheme(brightness, colorScheme),
      iconTheme: IconThemeData(
        color: colorScheme.onSurfaceVariant,
        size: 24.sp,
      ),
      dividerTheme: DividerThemeData(
        thickness: 1,
        color: colorScheme.outlineVariant,
        space: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainerLow,
        labelStyle: TextStyle(color: colorScheme.onSurface, fontSize: 12.sp),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      extensions: [
        AppCustomColors(
          success: AppColors.success,
          warning: AppColors.warning,
          appointmentPending: AppColors.pending,
          doctorOnline: AppColors.online,
          offline: AppColors.offline,
          chatBubbleMine: colorScheme.primary,
          chatBubbleOthers: colorScheme.surfaceContainerHigh,
          chatBubbleMineGradientStart: AppColors.headerGradientStart,
          chatBubbleMineGradientEnd: AppColors.headerGradientEnd,
          rating: AppColors.star,
          error: colorScheme.error,
        ),
      ],
    );
  }

  static TextTheme _textTheme(Brightness brightness, ColorScheme colorScheme) {
    final primaryColor = colorScheme.onSurface;
    final secondaryColor = colorScheme.onSurfaceVariant;
    final lightColor = colorScheme.onSurfaceVariant.withValues(alpha: 0.7);

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

  static InputDecorationTheme _inputDecorationTheme(
    Brightness brightness,
    ColorScheme colorScheme,
  ) {
    final isDark = brightness == Brightness.dark;

    return InputDecorationTheme(
      filled: true,
      fillColor: isDark
          ? colorScheme.surfaceContainerHigh
          : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      hintStyle: TextStyle(
        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
        fontSize: 14,
      ),
      labelStyle: TextStyle(color: colorScheme.onSurface, fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: _buildBorder(colorScheme.outlineVariant),
      enabledBorder: _buildBorder(colorScheme.outlineVariant),
      focusedBorder: _buildBorder(colorScheme.primary, width: 1.5),
      errorBorder: _buildBorder(colorScheme.error),
      focusedErrorBorder: _buildBorder(colorScheme.error, width: 1.5),
    );
  }

  static OutlineInputBorder _buildBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
