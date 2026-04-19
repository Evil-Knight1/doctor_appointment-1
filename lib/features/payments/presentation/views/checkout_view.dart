import 'package:doctor_appointment/core/utils/app_colors.dart';
import 'package:doctor_appointment/core/utils/app_styles.dart';
import 'package:doctor_appointment/core/utils/go_router.dart';
import 'package:doctor_appointment/features/on_boarding_view/presentation/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class CheckoutView extends StatefulWidget {
  const CheckoutView({super.key});

  @override
  State<CheckoutView> createState() => _CheckoutViewState();
}

class _CheckoutViewState extends State<CheckoutView> {
  int _selectedMethod = 0;

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
          'Payment',
          style: AppStyles.styleSemiBold22.copyWith(fontSize: 18.sp),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select Payment Method', style: AppStyles.styleSemiBold16),
            SizedBox(height: 16.h),
            _buildPaymentMethod(0, 'Credit/Debit Card', Icons.credit_card_rounded),
            SizedBox(height: 12.h),
            _buildPaymentMethod(1, 'PayPal', Icons.paypal_rounded),
            SizedBox(height: 12.h),
            _buildPaymentMethod(2, 'Apple Pay', Icons.apple_rounded),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Fees:', style: AppStyles.styleMedium14.copyWith(color: AppColors.textSecondary)),
                Text('\$15.00', style: AppStyles.styleSemiBold24.copyWith(color: AppColors.primary)),
              ],
            ),
            SizedBox(height: 24.h),
            CustomButton(
              text: 'Confirm Payment',
              onPressed: () {
                context.pushReplacement(AppRouter.kAppointmentSuccess);
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

  Widget _buildPaymentMethod(int index, String label, IconData icon) {
    final isSelected = _selectedMethod == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = index),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight : Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? AppColors.primary : AppColors.textSecondary, size: 28.sp),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                label,
                style: AppStyles.styleMedium14.copyWith(
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20.sp)
            else
              Icon(Icons.circle_outlined, color: AppColors.border, size: 20.sp),
          ],
        ),
      ),
    );
  }
}
