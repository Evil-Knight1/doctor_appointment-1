import 'package:doctor_appointment/core/theme/app_theme_extension.dart';
import 'package:doctor_appointment/features/appointment/domain/entities/appointment.dart';
import 'package:doctor_appointment/core/utils/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class PatientAppointmentHistoryView extends StatelessWidget {
  final int patientId;
  final String patientName;
  final List<Appointment> appointments;

  const PatientAppointmentHistoryView({
    super.key,
    required this.patientId,
    required this.patientName,
    required this.appointments,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final patientAppointments = appointments
        .where((app) => app.patientId == patientId)
        .toList()
      ..sort((a, b) => b.startTime.compareTo(a.startTime));

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
          '$patientName\'s History',
          style: context.styleSemiBold22.copyWith(fontSize: 18.sp, color: colorScheme.onSurface),
        ),
      ),
      body: patientAppointments.isEmpty
          ? Center(
              child: Text(
                'No appointment history found.',
                style: context.styleMedium14.copyWith(color: colorScheme.onSurfaceVariant),
              ),
            )
          : ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              itemCount: patientAppointments.length,
              separatorBuilder: (context, index) => SizedBox(height: 16.h),
              itemBuilder: (context, index) {
                final app = patientAppointments[index];
                return _buildAppointmentCard(context, app);
              },
            ),
    );
  }

  Widget _buildAppointmentCard(BuildContext context, Appointment appointment) {
    final colorScheme = Theme.of(context).colorScheme;
    final customColors = context.customColors;

    final statusText = appointment.status == 1
        ? 'Confirmed'
        : appointment.status == 2
        ? 'Completed'
        : appointment.status == 3
        ? 'Cancelled'
        : 'Pending';

    final statusColor = appointment.status == 1
        ? (customColors.success ?? Colors.green)
        : appointment.status == 2
        ? colorScheme.primary
        : appointment.status == 3
        ? colorScheme.error
        : (customColors.warning ?? Colors.orange);

    return InkWell(
      onTap: () {
        context.push(AppRouter.kAppointmentDetailsView, extra: {
          'appointment': appointment,
          'isDoctorFlow': true,
        });
      },
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: colorScheme.outlineVariant),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    statusText,
                    style: context.styleMedium14.copyWith(color: statusColor, fontSize: 12.sp),
                  ),
                ),
                Text(
                  'EGP ${appointment.amount?.toStringAsFixed(2) ?? "0.00"}',
                  style: context.styleSemiBold16.copyWith(color: colorScheme.primary),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Text(
              appointment.reason,
              style: context.styleSemiBold16.copyWith(color: colorScheme.onSurface),
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 16.sp,
                  color: colorScheme.primary,
                ),
                SizedBox(width: 6.w),
                Text(
                  DateFormat('MMM dd, yyyy').format(appointment.startTime),
                  style: context.styleMedium14.copyWith(color: colorScheme.onSurface),
                ),
                SizedBox(width: 16.w),
                Icon(
                  Icons.access_time_rounded,
                  size: 16.sp,
                  color: colorScheme.primary,
                ),
                SizedBox(width: 6.w),
                Text(
                  DateFormat('hh:mm a').format(appointment.startTime),
                  style: context.styleMedium14.copyWith(color: colorScheme.onSurface),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
