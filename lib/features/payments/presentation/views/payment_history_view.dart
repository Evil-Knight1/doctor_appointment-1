import 'package:doctor_appointment/core/utils/app_colors.dart';
import 'package:doctor_appointment/core/utils/app_styles.dart';
import 'package:doctor_appointment/core/utils/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class PaymentHistoryView extends StatelessWidget {
  const PaymentHistoryView({super.key});

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
          'Payment History',
          style: AppStyles.styleSemiBold22.copyWith(fontSize: 18.sp),
        ),
      ),
      body: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        itemCount: 5,
        separatorBuilder: (context, index) => SizedBox(height: 12.h),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              context.push(AppRouter.kTransactionDetailsView);
            },
            child: _buildTransactionCard(index),
          );
        },
      ),
    );
  }

  Widget _buildTransactionCard(int index) {
    final amounts = ['\$15.00', '\$20.00', '\$18.00', '\$15.00', '\$25.00'];
    final labels = ['Dentist Consultation', 'ENT Specialist', 'Ophthalmologist check', 'Follow-up', 'Therapy Session'];
    final statuses = ['Completed', 'Completed', 'Refunded', 'Completed', 'Completed'];
    
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.receipt_rounded, color: AppColors.primary, size: 24.sp),
              ),
              SizedBox(width: 14.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(labels[index % labels.length], style: AppStyles.styleMedium14),
                  SizedBox(height: 4.h),
                  Text(
                    statuses[index % statuses.length],
                    style: AppStyles.styleRegular12.copyWith(
                      color: statuses[index % statuses.length] == 'Refunded' ? Colors.red : Colors.green,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Text(amounts[index % amounts.length], style: AppStyles.styleSemiBold16),
        ],
      ),
    );
  }
}
