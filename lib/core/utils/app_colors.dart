import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary & Secondary
  static const primary = Color(0xFF247CFF);
  static const primaryLight = Color(0xFFEFF6FF);
  static const primaryDark = Color(0xFF1D4ED8);
  static const accent = Color(0xFFEF4444);
  static const secondary = Color(0xFF10B981);

  // ── Text ──
  static const textPrimary = Color(0xFF111827); // or 0xFF242424
  static const textSecondary = Color(0xFF6B7280); // or 0xFF757575
  static const textLight = Color(0xFF9CA3AF); // or 0xFFC2C2C2
  static const textHint = Color(0xFFB0B7C3);

  // Neutral Colors (Dark Mode)
  static const darkBg = Color(0xFF0F172A); 
  static const darkSurface = Color(0xFF1E293B);
  static const darkBorder = Color(0xFF334155);
  static const darkTextPrimary = Color(0xFFF8FAFC);
  static const darkTextSecondary = Color(0xFF94A3B8);
  static const darkTextLight = Color(0xFF64748B);

  // ── Surface / Background ──
  static const bg = Color(0xFFF9FAFB);
  static const backgroundLight = Color(0xFFF9FAFB);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceVariant = Color(0xFFF3F4F6);
  static const border = Color(0xFFE5E7EB); // merged border and divider
  static const divider = Color(0xFFE5E7EB);

  // Functional
  static const gray100 = Color(0xFFF1F5F9);
  static const gray200 = Color(0xFFE2E8F0);
  static const white = Color(0xFFFFFFFF);
  static const black = Color(0xFF000000);

  // ── Feedback ──
  static const star = Color(0xFFF59E0B);
  static const green = Color(0xFF10B981);

  // ── Shadows ──
  static const cardShadow = Color(0xFF1B2838);

  // ── Header gradient ──
  static const headerGradientStart = Color(0xFF2563EB);
  static const headerGradientEnd = Color(0xFF1D4ED8);
}
