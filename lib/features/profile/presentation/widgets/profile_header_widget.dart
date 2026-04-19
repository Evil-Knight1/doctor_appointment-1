import 'package:doctor_appointment/core/utils/app_colors.dart';
import 'package:doctor_appointment/core/utils/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:convert';
import 'package:doctor_appointment/core/services/shared_preferences_helper.dart';

class ProfileHeaderWidget extends StatelessWidget {
  final String name;
  final String email;

  const ProfileHeaderWidget({
    super.key,
    required this.name,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    String name = 'Guest User';
    String email = 'email@example.com';
    final userDataString = SharedPreferencesHelper.getUserData();
    if (userDataString != null) {
      try {
        final userData = jsonDecode(userDataString);
        email = userData['email'] ?? email;
        name = userData['fullName'] ?? userData['name'] ?? userData['userName'] ?? email.split('@').first;
      } catch (e) {
        // Ignored
      }
    }

    return Column(
      children: [
        SizedBox(height: 16.h),
        Stack(
          children: [
            CircleAvatar(
              radius: 45.r,
              backgroundColor: AppColors.primaryLight,
              child: Icon(
                Icons.person_rounded,
                size: 50.sp,
                color: AppColors.primary,
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 26.w,
                height: 26.h,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Icon(Icons.edit, color: Colors.white, size: 13.sp),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Text(
          name,
          style: AppStyles.styleSemiBold22.copyWith(fontSize: 18.sp),
        ),
        SizedBox(height: 4.h),
        Text(
          email,
          style: AppStyles.styleRegular14.copyWith(
            color: AppColors.textSecondary,
            fontSize: 13.sp,
          ),
        ),
        SizedBox(height: 24.h),
      ],
    );
  }
}
