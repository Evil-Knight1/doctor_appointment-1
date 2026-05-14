import 'package:flutter/material.dart';

class SpecialtyTheme {
  final IconData icon;
  final Color color;
  final Color bgColor;

  const SpecialtyTheme({
    required this.icon,
    required this.color,
    required this.bgColor,
  });
}

class SpecialtyMapper {
  static SpecialtyTheme getThemeForSpecialty(String? name, ColorScheme colorScheme) {
    final lowerName = (name ?? '').toLowerCase();
    final isDark = colorScheme.brightness == Brightness.dark;

    if (lowerName.contains('cardio')) {
      return SpecialtyTheme(
        icon: Icons.favorite_rounded,
        color: const Color(0xFFE11D48),
        bgColor: const Color(0xFFE11D48).withValues(alpha: isDark ? 0.2 : 0.1),
      );
    }
    if (lowerName.contains('neuro')) {
      return SpecialtyTheme(
        icon: Icons.psychology_rounded,
        color: const Color(0xFF7C3AED),
        bgColor: const Color(0xFF7C3AED).withValues(alpha: isDark ? 0.2 : 0.1),
      );
    }
    if (lowerName.contains('dent')) {
      return SpecialtyTheme(
        icon: Icons.health_and_safety_rounded,
        color: const Color(0xFF059669),
        bgColor: const Color(0xFF059669).withValues(alpha: isDark ? 0.2 : 0.1),
      );
    }
    if (lowerName.contains('pedia')) {
      return SpecialtyTheme(
        icon: Icons.child_care_rounded,
        color: const Color(0xFFD97706),
        bgColor: const Color(0xFFD97706).withValues(alpha: isDark ? 0.2 : 0.1),
      );
    }
    if (lowerName.contains('derm')) {
      return SpecialtyTheme(
        icon: Icons.face_rounded,
        color: const Color(0xFFDB2777),
        bgColor: const Color(0xFFDB2777).withValues(alpha: isDark ? 0.2 : 0.1),
      );
    }
    if (lowerName.contains('ortho')) {
      return SpecialtyTheme(
        icon: Icons.medical_services_rounded,
        color: const Color(0xFF2563EB),
        bgColor: const Color(0xFF2563EB).withValues(alpha: isDark ? 0.2 : 0.1),
      );
    }
    if (lowerName.contains('optomet')) {
      return SpecialtyTheme(
        icon: Icons.visibility_outlined,
        color: const Color(0xFF2563EB),
        bgColor: const Color(0xFF2563EB).withValues(alpha: isDark ? 0.2 : 0.1),
      );
    }
    if (lowerName.contains('pulmon')) {
      return SpecialtyTheme(
        icon: Icons.air_outlined,
        color: const Color(0xFF0891B2),
        bgColor: const Color(0xFF0891B2).withValues(alpha: isDark ? 0.2 : 0.1),
      );
    }
    if (lowerName.contains('ent')) {
      return SpecialtyTheme(
        icon: Icons.hearing_outlined,
        color: const Color(0xFF4F46E5),
        bgColor: const Color(0xFF4F46E5).withValues(alpha: isDark ? 0.2 : 0.1),
      );
    }

    // Default
    return SpecialtyTheme(
      icon: Icons.medical_services_outlined,
      color: colorScheme.primary,
      bgColor: colorScheme.primaryContainer.withValues(alpha: isDark ? 0.5 : 0.3),
    );
  }
}
