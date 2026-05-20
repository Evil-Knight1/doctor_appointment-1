import 'package:doctor_appointment/core/theme/app_theme_extension.dart';
import 'package:doctor_appointment/features/doctor_flow/logic/doctor_appointments_cubit.dart';
import 'package:doctor_appointment/features/doctor_flow/logic/doctor_appointments_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:doctor_appointment/features/doctor_flow/presentation/views/patient_appointment_history_view.dart';

class DoctorPatientsView extends StatelessWidget {
  const DoctorPatientsView({super.key});

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
          'My Patients',
          style: context.styleSemiBold22.copyWith(fontSize: 18.sp, color: colorScheme.onSurface),
        ),
      ),
      body: BlocBuilder<DoctorAppointmentsCubit, DoctorAppointmentsState>(
        builder: (context, state) {
          if (state is DoctorAppointmentsLoading) {
            return Skeletonizer(
              enabled: true,
              child: ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                itemCount: 5,
                separatorBuilder: (context, index) =>
                    Divider(color: colorScheme.outlineVariant, height: 24.h),
                itemBuilder: (context, index) => _buildSkeletonTile(context),
              ),
            );
          }

          if (state is DoctorAppointmentsFailure) {
            return Center(
              child: Text(
                state.message,
                style: TextStyle(color: colorScheme.error),
              ),
            );
          }

          if (state is DoctorAppointmentsSuccess) {
            final appointments = state.appointments;
            
            // Map: PatientId -> PatientName
            final uniquePatients = <int, String>{};
            // Map: PatientId -> LastVisit Date
            final lastVisitMap = <int, DateTime>{};

            for (final app in appointments) {
              uniquePatients[app.patientId] = app.patientName;
              final currentLast = lastVisitMap[app.patientId];
              if (currentLast == null || app.startTime.isAfter(currentLast)) {
                lastVisitMap[app.patientId] = app.startTime;
              }
            }

            if (uniquePatients.isEmpty) {
              return Center(
                child: Text(
                  'No patients found.',
                  style: context.styleMedium14.copyWith(color: colorScheme.onSurfaceVariant),
                ),
              );
            }

            final patientIds = uniquePatients.keys.toList();

            return ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              itemCount: patientIds.length,
              separatorBuilder: (context, index) =>
                  Divider(color: colorScheme.outlineVariant, height: 24.h),
              itemBuilder: (context, index) {
                final patientId = patientIds[index];
                final patientName = uniquePatients[patientId]!;
                final lastVisit = lastVisitMap[patientId];
                final initials = patientName.isNotEmpty
                    ? patientName.split(' ').map((e) => e[0]).take(2).join().toUpperCase()
                    : 'P';

                return InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => PatientAppointmentHistoryView(
                          patientId: patientId,
                          patientName: patientName,
                          appointments: appointments,
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24.r,
                          backgroundColor: colorScheme.primaryContainer,
                          child: Text(
                            initials,
                            style: context.styleSemiBold16.copyWith(color: colorScheme.primary),
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                patientName,
                                style: context.styleSemiBold16.copyWith(color: colorScheme.onSurface),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                lastVisit != null
                                    ? 'Last visit: ${DateFormat('dd MMM yyyy').format(lastVisit)}'
                                    : 'Pending visit',
                                style: context.styleMedium14.copyWith(color: colorScheme.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: colorScheme.outline,
                          size: 24.sp,
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildSkeletonTile(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        CircleAvatar(
          radius: 24.r,
          backgroundColor: colorScheme.primaryContainer,
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 120.w,
                height: 16.h,
                color: Colors.grey,
              ),
              SizedBox(height: 8.h),
              Container(
                width: 150.w,
                height: 14.h,
                color: Colors.grey,
              ),
            ],
          ),
        ),
        Icon(
          Icons.chevron_right_rounded,
          color: colorScheme.outline,
          size: 24.sp,
        ),
      ],
    );
  }
}
