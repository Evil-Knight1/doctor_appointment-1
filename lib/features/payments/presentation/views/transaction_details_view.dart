import 'package:doctor_appointment/core/utils/app_colors.dart';
import 'package:doctor_appointment/core/utils/app_styles.dart';
import 'package:doctor_appointment/features/on_boarding_view/presentation/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class TransactionDetailsView extends StatelessWidget {
  const TransactionDetailsView({super.key});

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
          'Transaction Details',
          style: AppStyles.styleSemiBold22.copyWith(fontSize: 18.sp),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          children: [
            Center(
              child: Column(
                children: [
                  Container(
                    height: 80.h,
                    width: 80.w,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 40.sp),
                  ),
                  SizedBox(height: 16.h),
                  Text('Payment Success', style: AppStyles.styleSemiBold22),
                  SizedBox(height: 8.h),
                  Text('\$15.00', style: AppStyles.styleSemiBold24.copyWith(color: AppColors.primary)),
                ],
              ),
            ),
            SizedBox(height: 48.h),
            _buildDetailRow('Transaction ID', '#TRX-93827461'),
            _buildDetailRow('Date & Time', '12 Oct 2023, 10:00 AM'),
            _buildDetailRow('Payment Method', 'Visa ending in **** 4123'),
            _buildDetailRow('Pay to', 'MediGuide Clinics'),
            _buildDetailRow('Service', 'Dentist Consultation'),
            const Spacer(),
            CustomButton(
              text: 'Download Receipt',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Receipt downloaded successfully')));
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppStyles.styleRegular14.copyWith(color: AppColors.textSecondary)),
          Text(value, style: AppStyles.styleSemiBold16),
        ],
      ),
    );
  }
}
