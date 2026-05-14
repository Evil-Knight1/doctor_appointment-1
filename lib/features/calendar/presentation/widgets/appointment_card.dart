import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:doctor_appointment/core/utils/go_router.dart';
import 'package:doctor_appointment/core/utils/app_styles.dart';

class AppointmentCard extends StatelessWidget {
  final String name;
  final String specialty;
  final String date;
  final String time;
  final String imageAsset;
  final bool isCompleted;
  final bool isCancelled;

  const AppointmentCard({
    super.key,
    required this.name,
    required this.specialty,
    required this.date,
    required this.time,
    required this.imageAsset,
    this.isCompleted = false,
    this.isCancelled = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push(AppRouter.kAppointmentDetailsView, extra: {
          'name': name,
          'specialty': specialty,
          'date': date,
          'time': time,
          'imageAsset': imageAsset,
          'isCompleted': isCompleted,
          'isCancelled': isCancelled,
        });
      },
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Theme.of(context).dividerColor),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildDoctorRow(context),
            SizedBox(height: 12.h),
            Divider(color: Theme.of(context).dividerColor, height: 1),
            SizedBox(height: 12.h),
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorRow(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: Image.asset(
            imageAsset,
            width: 55.w,
            height: 55.w,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(
              width: 55.w,
              height: 55.w,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(Icons.person, color: colorScheme.primary, size: 28.sp),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: AppStyles.styleMedium14.copyWith(
                  fontSize: 14.sp,
                  color: colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                specialty,
                style: AppStyles.styleRegular12.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: 6.h),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 12.sp,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    date,
                    style: AppStyles.styleRegular12.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 11.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Icon(
                    Icons.access_time_rounded,
                    size: 12.sp,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    time,
                    style: AppStyles.styleRegular12.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 11.sp,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: colorScheme.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
              padding: EdgeInsets.symmetric(vertical: 10.h),
            ),
            child: Text(
              'Re-book',
              style: AppStyles.styleMedium14.copyWith(
                color: colorScheme.primary,
                fontSize: 12.sp,
              ),
            ),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: isCompleted || isCancelled
                  ? colorScheme.error
                  : colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
              padding: EdgeInsets.symmetric(vertical: 10.h),
              elevation: 0,
            ),
            child: Text(
              isCompleted || isCancelled ? 'Leave Review' : 'Cancel',
              style: AppStyles.styleMedium14.copyWith(
                color: colorScheme.onPrimary,
                fontSize: 12.sp,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
