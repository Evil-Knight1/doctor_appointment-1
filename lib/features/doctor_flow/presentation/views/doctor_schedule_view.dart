import 'package:doctor_appointment/core/theme/app_theme_extension.dart';

import 'package:doctor_appointment/features/appointment/domain/entities/appointment.dart';
import 'package:doctor_appointment/features/doctor_flow/logic/doctor_appointments_cubit.dart';
import 'package:doctor_appointment/features/doctor_flow/logic/doctor_appointments_state.dart';
import 'package:doctor_appointment/core/utils/result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:doctor_appointment/core/utils/image_url_helper.dart';

class DoctorScheduleView extends StatelessWidget {
  const DoctorScheduleView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'My Schedule',
          style: context.styleSemiBold18.copyWith(color: colorScheme.onSurface),
        ),
      ),
      body: BlocBuilder<DoctorAppointmentsCubit, DoctorAppointmentsState>(
        builder: (context, state) {
          final isLoading = state is DoctorAppointmentsLoading;
          final appointments = state is DoctorAppointmentsSuccess
              ? state.appointments
              : [];

          if (state is DoctorAppointmentsFailure) {
            return Center(
              child: Text(
                state.message,
                style: TextStyle(color: colorScheme.error),
              ),
            );
          }

          if (state is DoctorAppointmentsSuccess && appointments.isEmpty) {
            return Center(
              child: Text(
                'No appointments scheduled yet.',
                style: context.styleMedium14.copyWith(color: colorScheme.onSurfaceVariant),
              ),
            );
          }

          return Skeletonizer(
            enabled: isLoading,
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              itemCount: isLoading ? 5 : appointments.length,
              separatorBuilder: (context, index) => SizedBox(height: 16.h),
              itemBuilder: (context, index) {
                return _buildScheduleRequest(
                  context,
                  isLoading
                      ? Appointment(
                          id: 0,
                          patientName: 'Patient Name',
                          reason: 'Appointment Reason',
                          status: 0,
                          startTime: DateTime.now(),
                          endTime: DateTime.now(),
                          doctorId: 0,
                          patientId: 0,
                          doctorName: '',
                          isPaid: false,
                          paymentMethod: null,
                          paymentStatus: null,
                          paymentTransactionId: '',
                          paymentDate: null,
                          amount: 0,
                          doctorNotes: '',
                          createdAt: DateTime.now(),
                        )
                      : appointments[index],
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildScheduleRequest(BuildContext context, Appointment appointment) {
    final colorScheme = Theme.of(context).colorScheme;
    final customColors = context.customColors;

    // 0 = Pending, 1 = Confirmed, 2 = Completed, 3 = Cancelled
    final statusIsPending = appointment.status == 0;
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

    return Container(
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
            children: [
              CircleAvatar(
                radius: 20.r,
                backgroundColor: colorScheme.secondaryContainer,
                backgroundImage: appointment.patientProfilePicture != null
                    ? CachedNetworkImageProvider(
                        ImageUrlHelper.getProfileImageUrl(appointment.patientProfilePicture!),
                      )
                    : null,
                child: appointment.patientProfilePicture == null
                    ? Icon(
                        Icons.person,
                        color: colorScheme.onSecondaryContainer,
                      )
                    : null,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment.patientName,
                      style: context.styleSemiBold16.copyWith(color: colorScheme.onSurface),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      appointment.reason,
                      style: context.styleRegular12.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              if (!statusIsPending)
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
            ],
          ),
          SizedBox(height: 16.h),
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
          if (statusIsPending) ...[
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      final cubit = context.read<DoctorAppointmentsCubit>();
                      final res = await cubit.updateStatus(appointment.id, 2); // 2 = Rejected
                      if (context.mounted) {
                        if (res is Success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Appointment declined successfully'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } else if (res is FailureResult<Appointment>) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(res.failure.message),
                              backgroundColor: colorScheme.error,
                            ),
                          );
                        }
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: colorScheme.error),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                    child: Text(
                      'Decline',
                      style: context.styleMedium14.copyWith(color: colorScheme.error),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final cubit = context.read<DoctorAppointmentsCubit>();
                      final res = await cubit.updateStatus(appointment.id, 1); // 1 = Approved
                      if (context.mounted) {
                        if (res is Success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Appointment accepted successfully'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } else if (res is FailureResult<Appointment>) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(res.failure.message),
                              backgroundColor: colorScheme.error,
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                    child: Text(
                      'Accept',
                      style: context.styleMedium14.copyWith(color: colorScheme.onPrimary),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
