import 'package:doctor_appointment/core/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

abstract class AppStyles {
  static TextStyle styleBold32 = TextStyle(
    fontSize: 32.sp,
    fontWeight: FontWeight.w700,
    fontFamily: 'Inter',
    color: AppColors.primary,
  );

  static TextStyle styleBold24 = TextStyle(
    fontSize: 24.sp,
    fontWeight: FontWeight.w700,
    fontFamily: 'Inter',
    color: AppColors.primary,
  );

  static TextStyle styleBold20 = TextStyle(
    fontSize: 20.sp,
    fontWeight: FontWeight.w700,
    fontFamily: 'Inter',
    color: AppColors.primary,
  );

  static TextStyle styleSemiBold24 = TextStyle(
    fontSize: 24.sp,
    fontWeight: FontWeight.w600,
    fontFamily: 'Inter',
    color: AppColors.textPrimary,
  );

  static TextStyle styleSemiBold22 = TextStyle(
    fontSize: 22.sp,
    fontWeight: FontWeight.w600,
    fontFamily: 'Inter',
    color: AppColors.textPrimary,
  );

  static TextStyle styleSemiBold18 = TextStyle(
    fontSize: 18.sp,
    fontWeight: FontWeight.w600,
    fontFamily: 'Inter',
    color: AppColors.textPrimary,
  );

  static TextStyle styleSemiBold16 = TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.w600,
    fontFamily: 'Inter',
    color: Colors.white,
  );

  static TextStyle styleMedium14 = TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.w500,
    fontFamily: 'Inter',
    color: AppColors.textPrimary,
  );

  static TextStyle styleRegular14 = TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.w400,
    fontFamily: 'Inter',
    color: AppColors.textSecondary,
  );

  static TextStyle styleMedium12 = TextStyle(
    fontSize: 12.sp,
    fontWeight: FontWeight.w500,
    fontFamily: 'Inter',
    color: AppColors.textPrimary,
  );

  static TextStyle styleRegular12 = TextStyle(
    fontSize: 12.sp,
    fontWeight: FontWeight.w400,
    fontFamily: 'Inter',
    color: AppColors.textSecondary,
  );

  static TextStyle styleRegular10 = TextStyle(
    fontSize: 10.sp,
    fontWeight: FontWeight.w400,
    fontFamily: 'Inter',
    color: AppColors.textSecondary,
  );

  static TextStyle styleMedium16 = TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.w500,
    fontFamily: 'Inter',
    color: AppColors.textPrimary,
  );

  static TextStyle? styleSemiBold20;
}
