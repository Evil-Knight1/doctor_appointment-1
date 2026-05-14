import 'package:doctor_appointment/features/doctors/data/models/availability_model.dart';
import 'package:doctor_appointment/features/doctors/logic/doctor_details_cubit.dart';
import 'package:doctor_appointment/features/doctors/logic/doctor_details_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:doctor_appointment/core/theme/app_theme_extension.dart';
import 'package:skeletonizer/skeletonizer.dart';

class DoctorWorkingTimeWidget extends StatelessWidget {
  const DoctorWorkingTimeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DoctorDetailsCubit, DoctorDetailsState>(
      builder: (context, state) {
        if (state is DoctorDetailsLoading || state is DoctorDetailsInitial) {
          return _buildLoading(context);
        }

        if (state is DoctorDetailsLoaded) {
          final availability = state.availability;
          if (availability.isEmpty) {
            return _buildEmpty(context);
          }
          return _buildList(context, availability);
        }

        // Error or other state — show nothing for working time
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildLoading(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Skeletonizer(
        enabled: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: 120.w, height: 16.h, color: Colors.white),
            SizedBox(height: 12.h),
            ...List.generate(
              3,
              (i) => Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(width: 80.w, height: 14.h, color: Colors.white),
                    Container(width: 100.w, height: 14.h, color: Colors.white),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Working Time',
            style: context.styleSemiBold22.copyWith(fontSize: 16.sp),
          ),
          SizedBox(height: 12.h),
          Text(
            'No working hours set',
            style: context.styleMedium14.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context, List<AvailabilityModel> availability) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Working Time',
            style: context.styleSemiBold22.copyWith(fontSize: 16.sp),
          ),
          SizedBox(height: 12.h),
          ...availability.map(
            (a) => Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    a.dayName,
                    style: context.styleMedium14.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(a.timeRange, style: context.styleMedium14),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
