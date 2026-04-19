import 'package:doctor_appointment/core/utils/app_colors.dart';
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20.sp),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Add Medical Record',
          style: AppStyles.styleSemiBold22.copyWith(fontSize: 18.sp),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Record Title', style: AppStyles.styleMedium14),
            SizedBox(height: 8.h),
            const CustomTextFormField(
              hintText: 'e.g. Blood Test Results',
              textInputType: TextInputType.text,
            ),
            SizedBox(height: 20.h),
            Text('Doctor/Facility Name', style: AppStyles.styleMedium14),
            SizedBox(height: 8.h),
            const CustomTextFormField(
              hintText: 'e.g. Dr. Sarah',
              textInputType: TextInputType.text,
            ),
            SizedBox(height: 20.h),
            Text('Upload Document', style: AppStyles.styleMedium14),
            SizedBox(height: 8.h),
            _buildUploadBox(),
            SizedBox(height: 20.h),
            Text('Additional Notes', style: AppStyles.styleMedium14),
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
              textStyle: AppStyles.styleSemiBold16,
              buttonColor: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadBox() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 32.h),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border, style: BorderStyle.solid),
      ),
      child: Column(
        children: [
          Icon(Icons.cloud_upload_rounded, color: AppColors.primary, size: 40.sp),
          SizedBox(height: 12.h),
          Text(
            'Tap to upload PDF, JPG, or PNG',
            style: AppStyles.styleMedium14.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
