import 'package:cached_network_image/cached_network_image.dart';
import 'package:doctor_appointment/core/utils/result.dart';
import 'package:doctor_appointment/core/theme/app_theme_extension.dart';
import 'package:doctor_appointment/core/utils/app_images.dart';
import 'package:doctor_appointment/core/utils/image_url_helper.dart';
import 'package:doctor_appointment/features/appointment/domain/entities/appointment.dart';
import 'package:doctor_appointment/features/appointment/logic/appointments_cubit.dart';
import 'package:doctor_appointment/features/on_boarding_view/presentation/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:doctor_appointment/features/doctors/domain/entities/doctor.dart';
import 'package:doctor_appointment/features/doctors/domain/entities/specialization.dart';
import 'package:doctor_appointment/core/utils/routes.dart';

class AppointmentDetailsView extends StatelessWidget {
  final Appointment appointment;

  const AppointmentDetailsView({super.key, required this.appointment});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final isCancelled = appointment.status == 3;
    final isCompleted = appointment.status != 3 && appointment.endTime.isBefore(now);

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
            _buildDoctorHeader(context),
            SizedBox(height: 32.h),
            _buildInfoCard(context, isCancelled, isCompleted),
            SizedBox(height: 40.h),
            _buildActions(context, isCancelled, isCompleted),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Center(
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: colorScheme.primary.withValues(alpha: 0.1), width: 4),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 60.r,
              backgroundColor: colorScheme.primaryContainer,
              child: ClipOval(
                child: _buildDoctorAvatar(context),
              ),
            ),
          ),
        ),
        SizedBox(height: 20.h),
        Text(
          appointment.doctorName,
          style: context.styleSemiBold22.copyWith(fontSize: 20.sp),
        ),
        SizedBox(height: 4.h),
        Text(
          'Doctor',
          style: context.styleMedium14.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildDoctorAvatar(BuildContext context) {
    final profilePicture = appointment.doctorProfilePicture;
    if (profilePicture != null && profilePicture.trim().isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: ImageUrlHelper.getFullUrl(profilePicture),
        httpHeaders: ImageUrlHelper.getImageHeaders(),
        fit: BoxFit.cover,
        width: 120.r,
        height: 120.r,
        errorWidget: (_, _, _) => Image.asset(
          _getImageAsset(),
          fit: BoxFit.cover,
          width: 120.r,
          height: 120.r,
        ),
      );
    }

    return Image.asset(
      _getImageAsset(),
      fit: BoxFit.cover,
      width: 120.r,
      height: 120.r,
    );
  }

  Widget _buildInfoCard(BuildContext context, bool isCancelled, bool isCompleted) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildDetailRow(
            context,
            'Status',
            isCancelled 
                ? 'Cancelled' 
                : (isCompleted 
                    ? 'Completed' 
                    : (appointment.isCancellationRequested
                        ? 'Cancellation Requested'
                        : (appointment.isRescheduleRequested
                            ? (appointment.rescheduleApprovedAt != null ? 'Reschedule Approved' : 'Reschedule Requested')
                            : 'Upcoming'))),
            icon: Icons.info_outline_rounded,
            valueColor: isCancelled || appointment.isCancellationRequested
                ? context.customColors.error
                : (isCompleted ? context.customColors.success : colorScheme.primary),
          ),
          Divider(height: 24.h),
          _buildDetailRow(
            context,
            'Date',
            _formatDate(appointment.startTime),
            icon: Icons.calendar_today_rounded,
          ),
          Divider(height: 24.h),
          _buildDetailRow(
            context,
            'Time',
            _formatTime(appointment.startTime),
            icon: Icons.access_time_rounded,
          ),
          Divider(height: 24.h),
          _buildDetailRow(
            context,
            'Reason',
            appointment.reason,
            icon: Icons.chat_bubble_outline_rounded,
          ),
        ],
      ),
    );
  }

  Doctor _getDoctorFromAppointment() {
    return Doctor(
      id: appointment.doctorId,
      fullName: appointment.doctorName,
      email: '',
      phone: '',
      specializationId: 0,
      specialization: Specialization(
        id: 0,
        name: appointment.specializationName ?? 'Specialist',
      ),
      isApproved: true,
      totalReviews: 0,
      createdAt: DateTime.now(),
      profilePictureUrl: appointment.doctorProfilePicture,
      isAvailable: true,
      consultationFee: appointment.amount,
    );
  }

  Widget _buildActions(BuildContext context, bool isCancelled, bool isCompleted) {
    final colorScheme = Theme.of(context).colorScheme;
    if (!isCancelled && !isCompleted) {
      if (appointment.isCancellationRequested) {
        return Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: context.customColors.error?.withValues(alpha: 0.1) ?? Colors.red.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            children: [
              Icon(Icons.hourglass_empty_rounded, color: context.customColors.error),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  'Your cancellation request is pending review.',
                  style: context.styleMedium14.copyWith(color: context.customColors.error),
                ),
              ),
            ],
          ),
        );
      }

      if (appointment.isRescheduleRequested) {
        if (appointment.rescheduleApprovedAt != null) {
          final expiryTime = appointment.rescheduleApprovedAt!.add(const Duration(hours: 12));
          if (DateTime.now().isBefore(expiryTime)) {
            return CustomButton(
              text: 'Select New Slot',
              onPressed: () {
                // Here we will navigate to the booking date view but pass an extra flag or appointmentId
                context.pushNamed(
                  Routes.bookingDateView,
                  extra: {'doctor': _getDoctorFromAppointment(), 'rescheduleAppointmentId': appointment.id},
                );
              },
              width: double.infinity,
              height: 54.h,
              circleSize: 12.r,
              textStyle: context.styleSemiBold16,
              buttonColor: colorScheme.primary,
            );
          } else {
            return Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: context.customColors.error?.withValues(alpha: 0.1) ?? Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                'Reschedule window expired.',
                style: context.styleMedium14.copyWith(color: context.customColors.error),
                textAlign: TextAlign.center,
              ),
            );
          }
        }
        return Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.orange.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            children: [
              const Icon(Icons.access_time_rounded, color: Colors.orange),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  'Your reschedule request is pending doctor approval.',
                  style: context.styleMedium14.copyWith(color: Colors.orange),
                ),
              ),
            ],
          ),
        );
      }

      final bool canReschedule = DateTime.now().isBefore(appointment.startTime.subtract(const Duration(hours: 24)));

      return Column(
        children: [
          if (canReschedule)
            CustomButton(
              text: 'Request Reschedule',
              onPressed: () => _showRequestRescheduleDialog(context),
              width: double.infinity,
              height: 54.h,
              circleSize: 12.r,
              textStyle: context.styleSemiBold16,
              buttonColor: colorScheme.primary,
            )
          else
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                'Rescheduling is only allowed up to 24 hours before the appointment.',
                style: context.styleRegular12.copyWith(color: colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
            ),
          SizedBox(height: 16.h),
          OutlinedButton(
            onPressed: () => _showRequestCancelDialog(context),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: context.customColors.error ?? Colors.red),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              padding: EdgeInsets.symmetric(vertical: 14.h),
              minimumSize: Size(double.infinity, 54.h),
            ),
            child: Text(
              'Request Cancel',
              style: context.styleSemiBold16.copyWith(
                color: context.customColors.error,
              ),
            ),
          ),
        ],
      );
    } else {
      return CustomButton(
        text: isCompleted ? 'Leave Review' : 'Book Again',
        onPressed: () {
          if (isCompleted) {
            context.pushNamed(
              Routes.bookingReviewView,
              extra: _getDoctorFromAppointment(),
            );
          } else {
            context.pushNamed(
              Routes.bookingDateView,
              extra: _getDoctorFromAppointment(),
            );
          }
        },
        width: double.infinity,
        height: 54.h,
        circleSize: 12.r,
        textStyle: context.styleSemiBold16,
        buttonColor: isCompleted ? colorScheme.secondary : colorScheme.primary,
      );
    }
  }

  void _showRequestCancelDialog(BuildContext context) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Text(
          'Request Cancellation',
          style: context.styleSemiBold18,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Please provide a reason for cancelling your appointment with ${appointment.doctorName}.',
              style: context.styleRegular14.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 16.h),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                hintText: 'Cancellation reason...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Back',
              style: context.styleMedium14.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              final reason = reasonController.text.trim();
              if (reason.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a reason')),
                );
                return;
              }
              Navigator.pop(dialogContext);
              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);
              final result = await context.read<AppointmentsCubit>().requestCancel(appointment.id, reason);
              if (result is Success<void>) {
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Cancellation request submitted successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
                navigator.pop(); // Go back after request
              } else if (result is FailureResult<void>) {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(result.failure.message),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text(
              'Submit',
              style: context.styleSemiBold14.copyWith(
                color: context.customColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRequestRescheduleDialog(BuildContext context) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Text(
          'Request Reschedule',
          style: context.styleSemiBold18,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Please provide a reason for rescheduling your appointment with ${appointment.doctorName}.',
              style: context.styleRegular14.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 16.h),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                hintText: 'Reschedule reason...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Back',
              style: context.styleMedium14.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              final reason = reasonController.text.trim();
              if (reason.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a reason')),
                );
                return;
              }
              Navigator.pop(dialogContext);
              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);
              final result = await context.read<AppointmentsCubit>().requestReschedule(appointment.id, reason);
              if (result is Success<void>) {
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Reschedule request submitted successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
                navigator.pop(); // Go back after request
              } else if (result is FailureResult<void>) {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(result.failure.message),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text(
              'Submit',
              style: context.styleSemiBold14.copyWith(
                color: Theme.of(context).colorScheme.primary,
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
    String value, {
    required IconData icon,
    Color? valueColor,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(icon, size: 18.sp, color: colorScheme.primary),
        ),
        SizedBox(width: 12.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: context.styleRegular12.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              value,
              style: context.styleSemiBold16.copyWith(
                color: valueColor ?? colorScheme.onSurface,
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _getImageAsset() {
    final images = [
      Assets.imagesDrAyeshaRahman,
      Assets.imagesDrSarah,
      Assets.imagesDrNobleThorme,
    ];
    return images[appointment.doctorId % images.length];
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
