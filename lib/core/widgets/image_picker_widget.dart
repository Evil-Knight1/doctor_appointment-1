import 'dart:io';
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
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppStyles.styleMedium14(context).copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 12.h),
        Center(
          child: Stack(
            children: [
              Container(
                width: 100.w,
                height: 100.w,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  shape: BoxShape.circle,
                  image: imagePath != null
                      ? DecorationImage(
                          image: FileImage(File(imagePath!)),
                          fit: BoxFit.cover,
                        )
                      : null,
                  border: Border.all(
                    color: colorScheme.outlineVariant,
                    width: 2,
                  ),
                ),
                child: imagePath == null
                    ? Icon(
                        Icons.person_outline_rounded,
                        size: 40.sp,
                        color: colorScheme.onSurfaceVariant,
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
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.camera_alt_rounded,
                      size: 16.sp,
                      color: colorScheme.onPrimary,
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
    final colorScheme = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.photo_library_outlined, color: colorScheme.primary),
              title: const Text('Gallery'),
              onTap: () async {
                final path = await ImagePickerHelper.pickImage(source: ImageSource.gallery);
                onImageSelected(path);
                if (context.mounted) Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.camera_alt_outlined, color: colorScheme.primary),
              title: const Text('Camera'),
              onTap: () async {
                final path = await ImagePickerHelper.pickImage(source: ImageSource.camera);
                onImageSelected(path);
                if (context.mounted) Navigator.pop(context);
              },
            ),
            if (imagePath != null)
              ListTile(
                leading: Icon(Icons.delete_outline, color: colorScheme.error),
                title: Text(
                  'Remove',
                  style: TextStyle(color: colorScheme.error),
                ),
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
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppStyles.styleMedium14(context).copyWith(
            color: colorScheme.onSurface,
          ),
        ),
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
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: colorScheme.outlineVariant,
                        width: 1,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Icon(
                      Icons.add_photo_alternate_outlined,
                      color: colorScheme.primary,
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
                        decoration: BoxDecoration(
                          color: colorScheme.errorContainer.withValues(alpha: 0.8),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          size: 12.sp,
                          color: colorScheme.onErrorContainer,
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
