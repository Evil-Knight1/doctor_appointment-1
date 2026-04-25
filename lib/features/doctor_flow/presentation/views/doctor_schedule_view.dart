import 'package:doctor_appointment/core/services/service_locator.dart';
import 'package:doctor_appointment/core/utils/app_colors.dart';
import 'package:doctor_appointment/core/utils/app_styles.dart';
import 'package:doctor_appointment/features/appointment/domain/entities/appointment.dart';
import 'package:doctor_appointment/features/doctor_flow/logic/doctor_appointments_cubit.dart';
import 'package:doctor_appointment/features/doctor_flow/logic/doctor_appointments_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class DoctorScheduleView extends StatelessWidget {
  const DoctorScheduleView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'My Schedule',
          style: AppStyles.styleSemiBold22.copyWith(fontSize: 18.sp),
        ),
      ),
      body: BlocBuilder<DoctorAppointmentsCubit, DoctorAppointmentsState>(
        builder: (context, state) {
          if (state is DoctorAppointmentsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is DoctorAppointmentsFailure) {
            return Center(child: Text(state.message));
          } else if (state is DoctorAppointmentsSuccess) {
            if (state.appointments.isEmpty) {
              return Center(
                child: Text(
                  'No appointments scheduled yet.',
                  style: AppStyles.styleMedium14.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              );
            }
            return ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              itemCount: state.appointments.length,
              separatorBuilder: (context, index) => SizedBox(height: 16.h),
              itemBuilder: (context, index) {
                return _buildScheduleRequest(
                  context,
                  state.appointments[index],
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildScheduleRequest(BuildContext context, Appointment appointment) {
    // 0 = Pending, 1 = Confirmed, 2 = Completed, 3 = Cancelled (Assumption based on usual patterns)
    final statusIsPending = appointment.status == 0;
    final statusText = appointment.status == 1
        ? 'Confirmed'
        : appointment.status == 2
        ? 'Completed'
        : appointment.status == 3
        ? 'Cancelled'
        : 'Pending';
    final statusColor = appointment.status == 1
        ? Colors.green
        : appointment.status == 2
        ? Colors.blue
        : appointment.status == 3
        ? Colors.red
        : Colors.orange;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
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
                backgroundColor: AppColors.bg,
                child: Icon(Icons.person, color: AppColors.textSecondary),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment.patientName,
                      style: AppStyles.styleSemiBold16,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      appointment.reason,
                      style: AppStyles.styleRegular12.copyWith(
                        color: AppColors.textSecondary,
                      ),
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
                    style: AppStyles.styleMedium14.copyWith(
                      color: statusColor,
                      fontSize: 12.sp,
                    ),
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
                color: AppColors.primary,
              ),
              SizedBox(width: 6.w),
              Text(
                DateFormat('MMM dd, yyyy').format(appointment.startTime),
                style: AppStyles.styleMedium14,
              ),
              SizedBox(width: 16.w),
              Icon(
                Icons.access_time_rounded,
                size: 16.sp,
                color: AppColors.primary,
              ),
              SizedBox(width: 6.w),
              Text(
                DateFormat('hh:mm a').format(appointment.startTime),
                style: AppStyles.styleMedium14,
              ),
            ],
          ),
          if (statusIsPending) ...[
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Declined.')),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                    child: Text(
                      'Decline',
                      style: AppStyles.styleMedium14.copyWith(
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Accepted!')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                    child: Text(
                      'Accept',
                      style: AppStyles.styleMedium14.copyWith(
                        color: Colors.white,
                      ),
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
