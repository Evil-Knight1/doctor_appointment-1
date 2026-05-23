import 'package:cached_network_image/cached_network_image.dart';
import 'package:doctor_appointment/core/utils/result.dart';
import 'package:doctor_appointment/features/appointment/domain/entities/appointment.dart';
import 'package:doctor_appointment/core/theme/app_theme_extension.dart';
import 'package:doctor_appointment/features/appointment/logic/appointments_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:doctor_appointment/core/utils/go_router.dart';
import 'package:doctor_appointment/features/doctors/domain/entities/doctor.dart';
import 'package:doctor_appointment/features/doctors/domain/entities/specialization.dart';
import 'package:doctor_appointment/core/utils/routes.dart';

class AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final bool isCompleted;
  final bool isCancelled;

  const AppointmentCard({
    super.key,
    required this.appointment,
    this.isCompleted = false,
    this.isCancelled = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push(AppRouter.kAppointmentDetailsView, extra: appointment);
      },
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
          ),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [_buildDoctorInfo(context), _buildStatusBadge(context)],
            ),
            SizedBox(height: 16.h),
            _buildDateTimeRow(context),
            SizedBox(height: 16.h),
            Divider(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
              height: 1,
            ),
            SizedBox(height: 16.h),
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorInfo(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final pictureUrl = appointment.doctorProfilePicture;
    final initials = appointment.doctorName.isNotEmpty
        ? appointment.doctorName
              .split(' ')
              .where((w) => w.isNotEmpty)
              .take(2)
              .map((w) => w[0].toUpperCase())
              .join()
        : 'Dr';

    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.r),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14.r),
            child: pictureUrl != null && pictureUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: pictureUrl,
                    width: 50.w,
                    height: 50.w,
                    fit: BoxFit.cover,
                    errorWidget: (_, _, _) =>
                        _buildInitialsAvatar(initials, colorScheme),
                  )
                : _buildInitialsAvatar(initials, colorScheme),
          ),
        ),
        SizedBox(width: 14.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              appointment.doctorName.isNotEmpty
                  ? appointment.doctorName
                  : 'Unknown Doctor',
              style: context.styleSemiBold16.copyWith(
                fontSize: 15.sp,
                color: colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              appointment.specializationName ?? 'Doctor',
              style: context.styleRegular12.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInitialsAvatar(String initials, ColorScheme colorScheme) {
    return Container(
      width: 50.w,
      height: 50.w,
      color: colorScheme.primaryContainer.withValues(alpha: 0.5),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: colorScheme.primary,
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final successColor = context.customColors.success ?? Colors.green;
    final errorColor = context.customColors.error ?? Colors.red;

    Color bgColor;
    Color textColor;
    String label;

    if (isCancelled) {
      bgColor = errorColor.withValues(alpha: 0.1);
      textColor = errorColor;
      label = 'Cancelled';
    } else if (isCompleted) {
      bgColor = successColor.withValues(alpha: 0.1);
      textColor = successColor;
      label = 'Completed';
    } else if (appointment.isCancellationRequested) {
      bgColor = errorColor.withValues(alpha: 0.1);
      textColor = errorColor;
      label = 'Cancel Pending';
    } else if (appointment.isRescheduleRequested) {
      bgColor = Colors.orange.withValues(alpha: 0.1);
      textColor = Colors.orange;
      label = appointment.rescheduleApprovedAt != null
          ? 'Slot Select'
          : 'Reschedule Pending';
    } else {
      bgColor = colorScheme.primary.withValues(alpha: 0.1);
      textColor = colorScheme.primary;
      label = 'Upcoming';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        label,
        style: context.styleMedium12.copyWith(
          color: textColor,
          fontSize: 10.sp,
        ),
      ),
    );
  }

  Widget _buildDateTimeRow(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(
            Icons.calendar_month_rounded,
            size: 16.sp,
            color: colorScheme.primary,
          ),
          SizedBox(width: 6.w),
          Text(
            _formatDate(appointment.startTime),
            style: context.styleMedium12.copyWith(color: colorScheme.onSurface),
          ),
          SizedBox(width: 20.w),
          Icon(
            Icons.access_time_filled_rounded,
            size: 16.sp,
            color: colorScheme.primary,
          ),
          SizedBox(width: 6.w),
          Text(
            _formatTime(appointment.startTime),
            style: context.styleMedium12.copyWith(color: colorScheme.onSurface),
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

  Widget _buildActions(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isUpcoming =
        !isCompleted &&
        !isCancelled &&
        !appointment.isCancellationRequested &&
        !appointment.isRescheduleRequested;

    if (!isUpcoming && !isCompleted && !isCancelled) {
      return Center(
        child: Text(
          'Action pending. Tap for details.',
          style: context.styleMedium12.copyWith(color: Colors.orange),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              if (isUpcoming) {
                _showRequestRescheduleDialog(context);
              } else {
                context.pushNamed(
                  Routes.bookingDateView,
                  extra: _getDoctorFromAppointment(),
                );
              }
            },
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: colorScheme.primary.withValues(alpha: 0.5),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              padding: EdgeInsets.symmetric(vertical: 12.h),
            ),
            child: Text(
              !appointment.isRescheduleRequested &&
                      appointment.rescheduleApprovedAt == null
                  ? 'Req. Reschedule (${appointment.isRescheduleRequested})'
                  : 'Pedning',
              style: context.styleSemiBold14.copyWith(
                color: colorScheme.primary,
                fontSize: 13.sp,
              ),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              if (isUpcoming) {
                _showRequestCancelDialog(context);
              } else {
                context.pushNamed(
                  Routes.bookingReviewView,
                  extra: _getDoctorFromAppointment(),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isUpcoming
                  ? colorScheme.primary
                  : colorScheme.secondary,
              foregroundColor: colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              padding: EdgeInsets.symmetric(vertical: 12.h),
              elevation: 0,
            ),
            child: Text(
              isUpcoming ? 'Req. Cancel' : 'Leave Review',
              style: context.styleSemiBold14.copyWith(
                color: colorScheme.onPrimary,
                fontSize: 13.sp,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showRequestCancelDialog(BuildContext context) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Text('Request Cancellation', style: context.styleSemiBold18),
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
              final messenger = ScaffoldMessenger.of(context);
              final result = await context
                  .read<AppointmentsCubit>()
                  .requestCancel(appointment.id, reason);
              if (result is Success<void>) {
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Cancellation request submitted successfully',
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
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
        title: Text('Request Reschedule', style: context.styleSemiBold18),
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
              final messenger = ScaffoldMessenger.of(context);
              final result = await context
                  .read<AppointmentsCubit>()
                  .requestReschedule(appointment.id, reason);
              if (result is Success<void>) {
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Reschedule request submitted successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
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

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
