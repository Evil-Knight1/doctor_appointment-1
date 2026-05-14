import 'package:doctor_appointment/core/utils/app_styles.dart';
import 'package:doctor_appointment/features/on_boarding_view/presentation/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:doctor_appointment/core/utils/image_url_helper.dart';
import 'package:doctor_appointment/core/theme/app_theme_extension.dart';

class AppointmentDetailsView extends StatelessWidget {
  final Map<String, dynamic> appointmentData;

  const AppointmentDetailsView({super.key, required this.appointmentData});

  @override
  Widget build(BuildContext context) {
    final name = appointmentData['name'] ?? 'Doctor Name';
    final date = appointmentData['date'] ?? '12 Oct, 2023';
    final time = appointmentData['time'] ?? '10:00 AM';
    final image = appointmentData['imageAsset'] ?? appointmentData['image'];
    final isCancelled = appointmentData['isCancelled'] == true;
    final isCompleted = appointmentData['isCompleted'] == true;
    final fee = appointmentData['fee'] ?? '\$15.00';

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
          'Appointment Details',
          style: context.styleSemiBold18.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.r),
                child:
                    (image != null &&
                        (image.startsWith('http') ||
                            image.startsWith('https') ||
                            image.startsWith('/')))
                    ? CachedNetworkImage(
                        imageUrl: ImageUrlHelper.getFullUrl(image),
                        httpHeaders: ImageUrlHelper.getImageHeaders(),
                        width: 100.w,
                        height: 100.w,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          width: 100.w,
                          height: 100.w,
                          color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                        ),
                        errorWidget: (context, url, error) => Container(
                          width: 100.w,
                          height: 100.w,
                          color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                          child: Icon(
                            Icons.person,
                            color: colorScheme.primary,
                            size: 40.sp,
                          ),
                        ),
                      )
                    : Image.asset(
                        image ?? 'assets/images/doctor1.png',
                        width: 100.w,
                        height: 100.w,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 100.w,
                          height: 100.w,
                          color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                          child: Icon(
                            Icons.person,
                            color: colorScheme.primary,
                            size: 40.sp,
                          ),
                        ),
                      ),
              ),
            ),
            SizedBox(height: 16.h),
            Text(name, style: context.styleSemiBold22),
            SizedBox(height: 4.h),
            Text(
              'Dentist Specialist',
              style: context.styleMedium14.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 32.h),
            _buildDetailRow(
              context,
              'Status',
              isCancelled
                  ? 'Cancelled'
                  : (isCompleted ? 'Completed' : 'Upcoming'),
              isCancelled
                  ? context.customColors.error
                  : (isCompleted
                        ? context.customColors.success
                        : colorScheme.primary),
            ),
            _buildDetailRow(context, 'Date', date),
            _buildDetailRow(context, 'Time', time),
            _buildDetailRow(context, 'Consultation Fees', fee),
            SizedBox(height: 40.h),
            if (!isCancelled && !isCompleted) ...[
              CustomButton(
                text: 'Reschedule',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Rescheduling...')),
                  );
                },
                width: double.infinity,
                height: 50.h,
                circleSize: 12.r,
                textStyle: context.styleSemiBold16,
                buttonColor: colorScheme.primary,
              ),
              SizedBox(height: 16.h),
              OutlinedButton(
                onPressed: () => _showCancelDialog(context),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: context.customColors.error ?? Colors.red,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  minimumSize: Size(double.infinity, 50.h),
                ),
                child: Text(
                  'Cancel Appointment',
                  style: context.styleSemiBold16.copyWith(
                    color: context.customColors.error,
                  ),
                ),
              ),
            ] else ...[
              OutlinedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Mock rebook...')),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: colorScheme.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  minimumSize: Size(double.infinity, 50.h),
                ),
                child: Text(
                  'Book Again',
                  style: context.styleSemiBold16.copyWith(
                    color: colorScheme.primary,
                  ),
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          'Cancel Appointment',
          style: context.styleSemiBold22.copyWith(fontSize: 16.sp),
        ),
        content: Text(
          'Are you sure you want to cancel this appointment?',
          style: context.styleRegular14.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Back',
              style: context.styleMedium14.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              context.pop(); // Go back to calendar
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Appointment Cancelled Successfully'),
                ),
              );
            },
            child: Text(
              'Cancel',
              style: context.styleMedium14.copyWith(
                color: context.customColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value, [
    Color? valueColor,
  ]) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: context.styleRegular14.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: context.styleSemiBold16.copyWith(
              color: valueColor ?? colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
