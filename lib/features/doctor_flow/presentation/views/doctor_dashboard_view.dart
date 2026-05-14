import 'package:doctor_appointment/core/theme/app_theme_extension.dart';
import 'package:doctor_appointment/core/utils/app_styles.dart';
import 'package:doctor_appointment/features/doctor_flow/logic/doctor_stats_cubit.dart';
import 'package:doctor_appointment/features/doctor_flow/logic/doctor_stats_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skeletonizer/skeletonizer.dart';

class DoctorDashboardView extends StatelessWidget {
  const DoctorDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Dashboard',
          style: AppStyles.styleSemiBold22.copyWith(fontSize: 18.sp),
        ),
      ),
      body: BlocBuilder<DoctorStatsCubit, DoctorStatsState>(
        builder: (context, state) {
          if (state is DoctorStatsLoading) {
            return Skeletonizer(
              enabled: true,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Bone.text(words: 2),
                    SizedBox(height: 8.h),
                    const Bone.text(words: 4),
                    SizedBox(height: 24.h),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            context,
                            'Patients',
                            '00',
                            Icons.people,
                            Colors.grey,
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: _buildStatCard(
                            context,
                            'Revenue',
                            '\$000',
                            Icons.money,
                            Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            context,
                            'Appts',
                            '00',
                            Icons.calendar_today,
                            Colors.grey,
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: _buildStatCard(
                            context,
                            'Rating',
                            '0.0',
                            Icons.star,
                            Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24.h),
                    const Bone.text(words: 2),
                    SizedBox(height: 12.h),
                    _buildSummaryRow(context, 'Completed', 0, Colors.grey),
                    _buildSummaryRow(context, 'Pending', 0, Colors.grey),
                    _buildSummaryRow(context, 'Cancelled', 0, Colors.grey),
                  ],
                ),
              ),
            );
          } else if (state is DoctorStatsSuccess) {
            final stats = state.stats;
            return SingleChildScrollView(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Dashboard Overview', style: AppStyles.styleSemiBold22),
                  SizedBox(height: 8.h),
                  Text(
                    'Here is what\'s happening today.',
                    style: AppStyles.styleRegular14.copyWith(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          context,
                          'Patients',
                          stats.totalPatients.toString(),
                          Icons.people_alt_rounded,
                          Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: _buildStatCard(
                          context,
                          'Total Revenue',
                          '\$${stats.totalRevenue.toStringAsFixed(0)}',
                          Icons.attach_money_rounded,
                          context.customColors.success!,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          context,
                          'Appointments',
                          stats.totalAppointments.toString(),
                          Icons.calendar_today_rounded,
                          context.customColors.warning!,
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: _buildStatCard(
                          context,
                          'Avg Rating',
                          stats.averageRating.toStringAsFixed(1),
                          Icons.star_rounded,
                          context.customColors.rating!,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),
                  Text('Appointment Summary', style: AppStyles.styleSemiBold16),
                  SizedBox(height: 12.h),
                  _buildSummaryRow(
                    context,
                    'Completed',
                    stats.completedAppointments,
                    context.customColors.success!,
                  ),
                  _buildSummaryRow(
                    context,
                    'Pending',
                    stats.pendingAppointments,
                    context.customColors.warning!,
                  ),
                  _buildSummaryRow(
                    context,
                    'Cancelled',
                    stats.cancelledAppointments,
                    context.customColors.error!,
                  ),
                ],
              ),
            );
          } else if (state is DoctorStatsFailure) {
            return Center(child: Text(state.message));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildSummaryRow(BuildContext context, String label, int value, Color color) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        children: [
          Container(
            width: 12.w,
            height: 12.h,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: 12.w),
          Text(label, style: AppStyles.styleMedium14),
          const Spacer(),
          Text(
            value.toString(),
            style: AppStyles.styleMedium14.copyWith(
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, color: color, size: 24.sp),
          ),
          SizedBox(height: 12.h),
          Text(value, style: AppStyles.styleSemiBold22),
          SizedBox(height: 4.h),
          Text(
            title,
            style: AppStyles.styleMedium14.copyWith(
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ],
      ),
    );
  }
}
