import 'package:cached_network_image/cached_network_image.dart';
import 'package:doctor_appointment/core/utils/result.dart';
import 'package:doctor_appointment/core/theme/app_theme_extension.dart';
import 'package:doctor_appointment/core/utils/app_images.dart';
import 'package:doctor_appointment/core/utils/image_url_helper.dart';
import 'package:doctor_appointment/features/appointment/domain/entities/appointment.dart';
import 'package:doctor_appointment/features/appointment/logic/appointments_cubit.dart';
import 'package:doctor_appointment/features/on_boarding_view/presentation/widgets/custom_button.dart';
import 'package:doctor_appointment/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:doctor_appointment/features/doctors/domain/entities/doctor.dart';
import 'package:doctor_appointment/features/doctors/domain/entities/specialization.dart';
import 'package:doctor_appointment/core/utils/routes.dart';

class AppointmentDetailsView extends StatelessWidget {
  final Appointment appointment;
  final bool isDoctorFlow;

  const AppointmentDetailsView({
    super.key, 
    required this.appointment,
    this.isDoctorFlow = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final isCancelled = appointment.status == 3;
    final isCompleted =
        appointment.status != 3 && appointment.endTime.isBefore(now);

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
          l10n.appointmentDetails,
          style: context.styleSemiBold18.copyWith(color: colorScheme.onSurface),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          children: [
            _buildHeader(context),
            SizedBox(height: 32.h),
            _buildInfoCard(context, isCancelled, isCompleted),
            SizedBox(height: 40.h),
            _buildActions(context, isCancelled, isCompleted),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final name = isDoctorFlow ? appointment.patientName : appointment.doctorName;
    final subtitle = isDoctorFlow ? 'Patient' : l10n.doctor;

    return Column(
      children: [
        Center(
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: colorScheme.primary.withValues(alpha: 0.1),
                width: 4,
              ),
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
              child: ClipOval(child: _buildAvatar(context)),
            ),
          ),
        ),
        SizedBox(height: 20.h),
        Text(
          name,
          style: context.styleSemiBold22.copyWith(fontSize: 20.sp),
        ),
        SizedBox(height: 4.h),
        Text(
          subtitle,
          style: context.styleMedium14.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildAvatar(BuildContext context) {
    final profilePicture = isDoctorFlow ? appointment.patientProfilePicture : appointment.doctorProfilePicture;
    if (profilePicture != null && profilePicture.trim().isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: ImageUrlHelper.getFullUrl(profilePicture),
        httpHeaders: ImageUrlHelper.getImageHeaders(),
        fit: BoxFit.cover,
        width: 120.r,
        height: 120.r,
        errorWidget: (_, _, _) => isDoctorFlow ? Icon(Icons.person, size: 60.r) : Image.asset(
          _getImageAsset(),
          fit: BoxFit.cover,
          width: 120.r,
          height: 120.r,
        ),
      );
    }

    return isDoctorFlow ? Icon(Icons.person, size: 60.r) : Image.asset(
      _getImageAsset(),
      fit: BoxFit.cover,
      width: 120.r,
      height: 120.r,
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    bool isCancelled,
    bool isCompleted,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24.r),
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
          _buildDetailRow(
            context,
            l10n.status,
            isCancelled
                ? l10n.cancelled
                : (isCompleted
                      ? l10n.completed
                      : (appointment.isCancellationRequested
                            ? l10n.cancellationRequested
                            : ((appointment.isRescheduleRequested ||
                                      appointment.rescheduleApprovedAt != null)
                                  ? (appointment.rescheduleApprovedAt != null
                                        ? l10n.rescheduleApproved
                                        : l10n.rescheduleRequested)
                                  : l10n.upcoming))),
            icon: Icons.info_outline_rounded,
            valueColor: isCancelled || appointment.isCancellationRequested
                ? context.customColors.error
                : (isCompleted
                      ? context.customColors.success
                      : colorScheme.primary),
          ),
          Divider(height: 24.h),
          _buildDetailRow(
            context,
            l10n.date,
            _formatDate(appointment.startTime),
            icon: Icons.calendar_today_rounded,
          ),
          Divider(height: 24.h),
          _buildDetailRow(
            context,
            l10n.time,
            _formatTime(appointment.startTime),
            icon: Icons.access_time_rounded,
          ),
          Divider(height: 24.h),
          _buildDetailRow(
            context,
            l10n.reason,
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

  Widget _buildActions(
    BuildContext context,
    bool isCancelled,
    bool isCompleted,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    if (!isCancelled && !isCompleted) {
      // Build the reschedule widget (null if no reschedule state)
      Widget? rescheduleWidget;
      if (appointment.isRescheduleRequested ||
          appointment.rescheduleApprovedAt != null) {
        if (appointment.rescheduleApprovedAt != null) {
          final expiryTime = appointment.rescheduleApprovedAt!.add(
            const Duration(hours: 12),
          );
          if (DateTime.now().isBefore(expiryTime)) {
            rescheduleWidget = CustomButton(
              text: l10n.selectNewSlot,
              onPressed: () {
                context.pushNamed(
                  Routes.bookingDateView,
                  extra: {
                    'doctor': _getDoctorFromAppointment(),
                    'rescheduleAppointmentId': appointment.id,
                  },
                );
              },
              width: double.infinity,
              height: 54.h,
              circleSize: 12.r,
              textStyle: context.styleSemiBold16,
              buttonColor: colorScheme.primary,
            );
          } else {
            rescheduleWidget = Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color:
                    context.customColors.error?.withValues(alpha: 0.1) ??
                    Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                l10n.rescheduleWindowExpired,
                style: context.styleMedium14.copyWith(
                  color: context.customColors.error,
                ),
                textAlign: TextAlign.center,
              ),
            );
          }
        } else {
          // Pending doctor approval
          rescheduleWidget = Container(
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
                    l10n.reschedulePendingApproval,
                    style: context.styleMedium14.copyWith(color: Colors.orange),
                  ),
                ),
              ],
            ),
          );
        }
      }

      // Build the cancellation widget (null if not requested)
      Widget? cancellationWidget;
      if (appointment.isCancellationRequested) {
        cancellationWidget = Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color:
                context.customColors.error?.withValues(alpha: 0.1) ??
                Colors.red.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            children: [
              Icon(
                Icons.hourglass_empty_rounded,
                color: context.customColors.error,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  l10n.cancellationPendingReview,
                  style: context.styleMedium14.copyWith(
                    color: context.customColors.error,
                  ),
                ),
              ),
            ],
          ),
        );
      }

      // If either or both requests exist, stack the banners
      if (rescheduleWidget != null || cancellationWidget != null) {
        return Column(
          children: [
            ?rescheduleWidget,
            if (rescheduleWidget != null && cancellationWidget != null)
              SizedBox(height: 12.h),
            ?cancellationWidget,
          ],
        );
      }

      // No pending requests — show action buttons
      final bool canReschedule = DateTime.now().isBefore(
        appointment.startTime.subtract(const Duration(hours: 24)),
      );

      return Column(
        children: [
          if (canReschedule)
            CustomButton(
              text: l10n.requestReschedule,
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
                color: colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.5,
                ),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                l10n.rescheduleAllowedUpTo24Hours,
                style: context.styleRegular12.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
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
              l10n.requestCancel,
              style: context.styleSemiBold16.copyWith(
                color: context.customColors.error,
              ),
            ),
          ),
        ],
      );
    } else {
      return CustomButton(
        text: isCompleted ? l10n.leaveReview : l10n.bookAgain,
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
    final l10n = AppLocalizations.of(context)!;
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Text(l10n.requestCancellation, style: context.styleSemiBold18),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.cancelReasonPrompt(appointment.doctorName),
              style: context.styleRegular14.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 16.h),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                hintText: l10n.cancellationReasonHint,
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
              l10n.back,
              style: context.styleMedium14.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              final reason = reasonController.text.trim();
              if (reason.isEmpty) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(l10n.pleaseEnterReason)));
                return;
              }
              Navigator.pop(dialogContext);
              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);
              final result = await context
                  .read<AppointmentsCubit>()
                  .requestCancel(appointment.id, reason);
              if (result is Success<void>) {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(l10n.cancellationSubmittedSuccessfully),
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
              l10n.submit,
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
    final l10n = AppLocalizations.of(context)!;
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Text(l10n.requestReschedule, style: context.styleSemiBold18),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.rescheduleReasonPrompt(appointment.doctorName),
              style: context.styleRegular14.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 16.h),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                hintText: l10n.rescheduleReasonHint,
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
              l10n.back,
              style: context.styleMedium14.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              final reason = reasonController.text.trim();
              if (reason.isEmpty) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(l10n.pleaseEnterReason)));
                return;
              }
              Navigator.pop(dialogContext);
              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);
              final result = await context
                  .read<AppointmentsCubit>()
                  .requestReschedule(appointment.id, reason);
              if (result is Success<void>) {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(l10n.rescheduleSubmittedSuccessfully),
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
              l10n.submit,
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
