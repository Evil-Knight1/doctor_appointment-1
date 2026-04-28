import 'dart:io';
import 'package:doctor_appointment/core/utils/app_colors.dart';
import 'package:doctor_appointment/core/utils/app_styles.dart';
import 'package:doctor_appointment/core/utils/image_picker_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

class ProfileImagePicker extends StatelessWidget {
  final String? imagePath;
  final ValueChanged<String?> onImageSelected;
  final String label;

  const ProfileImagePicker({
    super.key,
    this.imagePath,
    required this.onImageSelected,
    this.label = 'Profile Picture',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppStyles.styleMedium14),
        SizedBox(height: 12.h),
        Center(
          child: Stack(
            children: [
              Container(
                width: 100.w,
                height: 100.w,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                  image: imagePath != null
                      ? DecorationImage(
                          image: FileImage(File(imagePath!)),
                          fit: BoxFit.cover,
                        )
                      : null,
                  border: Border.all(
                    color: const Color(0xFFE2E8F0),
                    width: 2,
                  ),
                ),
                child: imagePath == null
                    ? Icon(
                        Icons.person_outline_rounded,
                        size: 40.sp,
                        color: const Color(0xFF94A3B8),
                      )
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => _showPicker(context),
                  child: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.camera_alt_rounded,
                      size: 16.sp,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Gallery'),
              onTap: () async {
                final path = await ImagePickerHelper.pickImage(source: ImageSource.gallery);
                onImageSelected(path);
                if (context.mounted) Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Camera'),
              onTap: () async {
                final path = await ImagePickerHelper.pickImage(source: ImageSource.camera);
                onImageSelected(path);
                if (context.mounted) Navigator.pop(context);
              },
            ),
            if (imagePath != null)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('Remove', style: TextStyle(color: Colors.red)),
                onTap: () {
                  onImageSelected(null);
                  Navigator.pop(context);
                },
              ),
          ],
        ),
      ),
    );
  }
}

class MultiImagePicker extends StatelessWidget {
  final List<String> imagePaths;
  final ValueChanged<List<String>> onImagesSelected;
  final String label;

  const MultiImagePicker({
    super.key,
    required this.imagePaths,
    required this.onImagesSelected,
    this.label = 'Clinic Images',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppStyles.styleMedium14),
        SizedBox(height: 12.h),
        SizedBox(
          height: 80.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: imagePaths.length + 1,
            itemBuilder: (context, index) {
              if (index == imagePaths.length) {
                return GestureDetector(
                  onTap: () async {
                    final newImages = await ImagePickerHelper.pickMultiImage();
                    onImagesSelected([...imagePaths, ...newImages]);
                  },
                  child: Container(
                    width: 80.w,
                    margin: EdgeInsets.only(right: 12.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: const Color(0xFFE2E8F0),
                        width: 1,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Icon(
                      Icons.add_photo_alternate_outlined,
                      color: AppColors.primary,
                      size: 24.sp,
                    ),
                  ),
                );
              }

              return Stack(
                children: [
                  Container(
                    width: 80.w,
                    margin: EdgeInsets.only(right: 12.w),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.r),
                      image: DecorationImage(
                        image: FileImage(File(imagePaths[index])),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 16,
                    child: GestureDetector(
                      onTap: () {
                        final updated = List<String>.from(imagePaths)..removeAt(index);
                        onImagesSelected(updated);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          size: 12.sp,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
