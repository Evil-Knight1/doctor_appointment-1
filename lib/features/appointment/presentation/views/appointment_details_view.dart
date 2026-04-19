import 'package:doctor_appointment/core/utils/app_colors.dart';
import 'package:doctor_appointment/core/utils/app_styles.dart';
import 'package:doctor_appointment/features/on_boarding_view/presentation/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class AppointmentDetailsView extends StatelessWidget {
  final Map<String, dynamic> appointmentData;

  const AppointmentDetailsView({super.key, required this.appointmentData});

  @override
  Widget build(BuildContext context) {
    final name = appointmentData['name'] ?? 'Doctor Name';
    final date = appointmentData['date'] ?? '12 Oct, 2023';
    final time = appointmentData['time'] ?? '10:00 AM';
    final imageAsset = appointmentData['imageAsset'];
    final isCancelled = appointmentData['isCancelled'] == true;
    final isCompleted = appointmentData['isCompleted'] == true;

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
          'Appointment Details',
          style: AppStyles.styleSemiBold22.copyWith(fontSize: 18.sp),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.r),
                child: imageAsset != null
                    ? Image.asset(
                        imageAsset,
                        width: 100.w,
                        height: 100.w,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: 100.w,
                        height: 100.w,
                        color: AppColors.primaryLight,
                        child: Icon(Icons.person, color: AppColors.primary, size: 40.sp),
                      ),
              ),
            ),
            SizedBox(height: 16.h),
            Text(name, style: AppStyles.styleSemiBold22),
            SizedBox(height: 4.h),
            Text('Dentist Specialist', style: AppStyles.styleMedium14.copyWith(color: AppColors.textSecondary)),
            SizedBox(height: 32.h),
            _buildDetailRow('Status', isCancelled ? 'Cancelled' : (isCompleted ? 'Completed' : 'Upcoming'), 
                isCancelled ? Colors.red : (isCompleted ? Colors.green : AppColors.primary)),
            _buildDetailRow('Date', date),
            _buildDetailRow('Time', time),
            _buildDetailRow('Consultation Fees', '\$15.00'),
            SizedBox(height: 40.h),
            if (!isCancelled && !isCompleted) ...[
              CustomButton(
                text: 'Reschedule',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Rescheduling...')));
                },
                width: double.infinity,
                height: 50.h,
                circleSize: 12.r,
                textStyle: AppStyles.styleSemiBold16,
                buttonColor: AppColors.primary,
              ),
              SizedBox(height: 16.h),
              OutlinedButton(
                onPressed: () => _showCancelDialog(context),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  minimumSize: Size(double.infinity, 50.h),
                ),
                child: Text(
                  'Cancel Appointment',
                  style: AppStyles.styleSemiBold16.copyWith(color: Colors.red),
                ),
              ),
            ] else ...[
              OutlinedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mock rebook...')));
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  minimumSize: Size(double.infinity, 50.h),
                ),
                child: Text(
                  'Book Again',
                  style: AppStyles.styleSemiBold16.copyWith(color: AppColors.primary),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text('Canel Appointment', style: AppStyles.styleSemiBold22.copyWith(fontSize: 16.sp)),
        content: Text('Are you sure you want to cancel this appointment?', style: AppStyles.styleRegular14.copyWith(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Back', style: AppStyles.styleMedium14.copyWith(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              context.pop(); // Go back to calendar
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Appointment Cancelled Successfully')));
            },
            child: Text('Cancel', style: AppStyles.styleMedium14.copyWith(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, [Color? valueColor]) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppStyles.styleRegular14.copyWith(color: AppColors.textSecondary)),
          Text(value, style: AppStyles.styleSemiBold16.copyWith(color: valueColor ?? AppColors.textPrimary)),
        ],
      ),
    );
  }
}
