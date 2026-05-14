import 'package:doctor_appointment/core/utils/app_styles.dart';
import 'package:doctor_appointment/features/auth/presentation/widgets/custom_text_field.dart';
import 'package:doctor_appointment/features/on_boarding_view/presentation/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class CreateRecordView extends StatelessWidget {
  const CreateRecordView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: colorScheme.onSurface,
            size: 20.sp,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Add Medical Record',
          style: AppStyles.styleSemiBold22.copyWith(
            fontSize: 18.sp,
            color: colorScheme.onSurface,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Record Title',
              style: AppStyles.styleMedium14.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 8.h),
            const CustomTextFormField(
              hintText: 'e.g. Blood Test Results',
              textInputType: TextInputType.text,
            ),
            SizedBox(height: 20.h),
            Text(
              'Doctor/Facility Name',
              style: AppStyles.styleMedium14.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 8.h),
            const CustomTextFormField(
              hintText: 'e.g. Dr. Sarah',
              textInputType: TextInputType.text,
            ),
            SizedBox(height: 20.h),
            Text(
              'Upload Document',
              style: AppStyles.styleMedium14.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 8.h),
            _buildUploadBox(context),
            SizedBox(height: 20.h),
            Text(
              'Additional Notes',
              style: AppStyles.styleMedium14.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 8.h),
            const CustomTextFormField(
              hintText: 'Any extra details...',
              textInputType: TextInputType.text,
            ),
            SizedBox(height: 32.h),
            CustomButton(
              text: 'Save Record',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Record simulated successfully!')),
                );
                context.pop();
              },
              width: double.infinity,
              height: 50.h,
              circleSize: 12.r,
              textStyle: AppStyles.styleSemiBold16.copyWith(
                color: colorScheme.onPrimary,
              ),
              buttonColor: colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadBox(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 32.h),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: colorScheme.outlineVariant,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.cloud_upload_rounded,
            color: colorScheme.primary,
            size: 40.sp,
          ),
          SizedBox(height: 12.h),
          Text(
            'Tap to upload PDF, JPG, or PNG',
            style: AppStyles.styleMedium14.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

