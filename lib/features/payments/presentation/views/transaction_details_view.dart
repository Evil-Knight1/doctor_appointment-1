import 'package:doctor_appointment/core/utils/app_styles.dart';
import 'package:doctor_appointment/features/on_boarding_view/presentation/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class TransactionDetailsView extends StatelessWidget {
  const TransactionDetailsView({super.key});

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
          'Transaction Details',
          style: AppStyles.styleSemiBold22.copyWith(
            fontSize: 18.sp,
            color: colorScheme.onSurface,
          ),
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
                      color: colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_circle_rounded,
                      color: colorScheme.primary,
                      size: 40.sp,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Payment Success',
                    style: AppStyles.styleSemiBold22.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    '\$15.00',
                    style: AppStyles.styleSemiBold24.copyWith(
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 48.h),
            _buildDetailRow(context, 'Transaction ID', '#TRX-93827461'),
            _buildDetailRow(context, 'Date & Time', '12 Oct 2023, 10:00 AM'),
            _buildDetailRow(context, 'Payment Method', 'Visa ending in **** 4123'),
            _buildDetailRow(context, 'Pay to', 'MediGuide Clinics'),
            _buildDetailRow(context, 'Service', 'Dentist Consultation'),
            const Spacer(),
            CustomButton(
              text: 'Download Receipt',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Receipt downloaded successfully')),
                );
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

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppStyles.styleRegular14.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: AppStyles.styleSemiBold16.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
