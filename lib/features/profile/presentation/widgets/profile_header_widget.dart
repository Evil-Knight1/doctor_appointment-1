import 'package:cached_network_image/cached_network_image.dart';
import 'package:doctor_appointment/core/utils/app_colors.dart';
import 'package:doctor_appointment/core/utils/app_styles.dart';
import 'package:doctor_appointment/features/profile/domain/entities/patient_profile.dart';
import 'package:doctor_appointment/features/profile/logic/profile_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

/// Profile header widget that shows avatar (with image-change support),
/// user name and email.
class ProfileHeaderWidget extends StatefulWidget {
  final PatientProfile profile;

  const ProfileHeaderWidget({
    super.key,
    required this.profile,
  });

  @override
  State<ProfileHeaderWidget> createState() => _ProfileHeaderWidgetState();
}

class _ProfileHeaderWidgetState extends State<ProfileHeaderWidget> {
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'Change Profile Photo',
              style: AppStyles.styleSemiBold22.copyWith(fontSize: 16.sp),
            ),
            SizedBox(height: 16.h),
            _PickerOption(
              icon: Icons.camera_alt_outlined,
              label: 'Take a Photo',
              onTap: () async {
                Navigator.pop(bottomSheetContext);
                final image = await picker.pickImage(
                  source: ImageSource.camera,
                  imageQuality: 80,
                );
                if (image != null && mounted) {
                  _updateProfileImage(image.path);
                }
              },
            ),
            SizedBox(height: 4.h),
            _PickerOption(
              icon: Icons.photo_library_outlined,
              label: 'Choose from Gallery',
              onTap: () async {
                Navigator.pop(bottomSheetContext);
                final image = await picker.pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 80,
                );
                if (image != null && mounted) {
                  _updateProfileImage(image.path);
                }
              },
            ),
            if (widget.profile.profilePicture != null) ...[
              SizedBox(height: 4.h),
              _PickerOption(
                icon: Icons.delete_outline_rounded,
                label: 'Remove Photo',
                isDestructive: true,
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  _updateProfileImage(null);
                },
              ),
            ],
            SizedBox(height: 8.h),
          ],
        ),
      ),
    );
  }

  void _updateProfileImage(String? path) {
    context.read<ProfileCubit>().updateProfile(
      fullName: widget.profile.fullName,
      phone: widget.profile.phone,
      dateOfBirth: widget.profile.dateOfBirth,
      gender: widget.profile.gender,
      address: widget.profile.address,
      profilePicturePath: path,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              // Decorative background glow
              Container(
                width: 130.r,
                height: 130.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.15),
                      AppColors.primary.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
              // Avatar with edit overlay
              GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  children: [
                    // Avatar circle
                    Container(
                      width: 100.r,
                      height: 100.r,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(
                          color: AppColors.primaryLight,
                          width: 4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child:
                            widget.profile.profilePicture != null
                                ? CachedNetworkImage(
                                  imageUrl: widget.profile.profilePicture!,
                                  fit: BoxFit.cover,
                                  placeholder:
                                      (context, url) => Center(
                                        child: SizedBox(
                                          width: 24.w,
                                          height: 24.h,
                                          child:
                                              const CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: AppColors.primary,
                                              ),
                                        ),
                                      ),
                                  errorWidget:
                                      (context, url, error) => Icon(
                                        Icons.person_rounded,
                                        size: 56.sp,
                                        color: AppColors.primary,
                                      ),
                                )
                                : Icon(
                                  Icons.person_rounded,
                                  size: 56.sp,
                                  color: AppColors.primary,
                                ),
                      ),
                    ),
                    // Edit badge
                    Positioned(
                      bottom: 4,
                      right: 4,
                      child: Container(
                        width: 32.w,
                        height: 32.h,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.camera_alt_rounded,
                          color: Colors.white,
                          size: 15.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            widget.profile.fullName,
            style: AppStyles.styleSemiBold22.copyWith(
              fontSize: 22.sp,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            widget.profile.email,
            style: AppStyles.styleRegular14.copyWith(
              color: AppColors.textSecondary,
              fontSize: 14.sp,
            ),
          ),
          SizedBox(height: 12.h),
          // Edit Profile Button (Optional, or just the label)
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                'Change Photo',
                style: AppStyles.styleMedium14.copyWith(
                  color: AppColors.primary,
                  fontSize: 12.sp,
                ),
              ),
            ),
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }
}


class _PickerOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _PickerOption({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? AppColors.accent : AppColors.textPrimary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 4.w),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: isDestructive
                    ? AppColors.accent.withValues(alpha: 0.08)
                    : AppColors.primaryLight,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, color: color, size: 20.sp),
            ),
            SizedBox(width: 12.w),
            Text(label, style: AppStyles.styleMedium14.copyWith(color: color)),
          ],
        ),
      ),
    );
  }
}
