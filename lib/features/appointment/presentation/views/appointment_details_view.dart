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
            isCancelled ? 'Cancelled' : (isCompleted ? 'Completed' : 'Upcoming'),
            icon: Icons.info_outline_rounded,
            valueColor: isCancelled
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
      return Column(
        children: [
          CustomButton(
            text: 'Reschedule',
            onPressed: () {
              context.pushNamed(
                Routes.bookingDateView,
                extra: _getDoctorFromAppointment(),
              );
            },
            width: double.infinity,
            height: 54.h,
            circleSize: 12.r,
            textStyle: context.styleSemiBold16,
            buttonColor: colorScheme.primary,
          ),
          SizedBox(height: 16.h),
          OutlinedButton(
            onPressed: () => _showCancelDialog(context),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: context.customColors.error ?? Colors.red),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              padding: EdgeInsets.symmetric(vertical: 14.h),
              minimumSize: Size(double.infinity, 54.h),
            ),
            child: Text(
              'Cancel Appointment',
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

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Text(
          'Cancel Appointment',
          style: context.styleSemiBold18,
        ),
        content: Text(
          'Are you sure you want to cancel your appointment with ${appointment.doctorName}?',
          style: context.styleRegular14.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
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
              Navigator.pop(dialogContext);
              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);
              final result = await context.read<AppointmentsCubit>().cancelAppointment(appointment.id);
              if (result is Success<void>) {
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Appointment cancelled successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
                navigator.pop(); // Go back after cancellation
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
              'Yes, Cancel',
              style: context.styleSemiBold14.copyWith(
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
