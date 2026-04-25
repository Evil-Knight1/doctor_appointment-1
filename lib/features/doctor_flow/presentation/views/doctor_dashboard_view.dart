import 'package:doctor_appointment/core/services/service_locator.dart';
import 'package:doctor_appointment/core/utils/app_colors.dart';
import 'package:doctor_appointment/core/utils/app_styles.dart';
import 'package:doctor_appointment/features/doctor_flow/logic/doctor_stats_cubit.dart';
import 'package:doctor_appointment/features/doctor_flow/logic/doctor_stats_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DoctorDashboardView extends StatelessWidget {
  const DoctorDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<DoctorStatsCubit>()..fetchStats(),
      child: Scaffold(
        backgroundColor: AppColors.bg,
        appBar: AppBar(
          backgroundColor: Colors.white,
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
              return const Center(child: CircularProgressIndicator());
            } else if (state is DoctorStatsSuccess) {
              final stats = state.stats;
              return SingleChildScrollView(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dashboard Overview',
                      style: AppStyles.styleSemiBold22,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Here is what\'s happening today.',
                      style: AppStyles.styleRegular14.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 24.h),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Patients',
                            stats.totalPatients.toString(),
                            Icons.people_alt_rounded,
                            AppColors.primary,
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: _buildStatCard(
                            'Total Revenue',
                            '\$${stats.totalRevenue.toStringAsFixed(0)}',
                            Icons.attach_money_rounded,
                            AppColors.green,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Appointments',
                            stats.totalAppointments.toString(),
                            Icons.calendar_today_rounded,
                            Colors.orange,
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: _buildStatCard(
                            'Avg Rating',
                            stats.averageRating.toStringAsFixed(1),
                            Icons.star_rounded,
                            Colors.amber,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24.h),
                    Text(
                      'Appointment Summary',
                      style: AppStyles.styleSemiBold16,
                    ),
                    SizedBox(height: 12.h),
                    _buildSummaryRow(
                      'Completed',
                      stats.completedAppointments,
                      AppColors.green,
                    ),
                    _buildSummaryRow(
                      'Pending',
                      stats.pendingAppointments,
                      Colors.orange,
                    ),
                    _buildSummaryRow(
                      'Cancelled',
                      stats.cancelledAppointments,
                      Colors.red,
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
      ),
    );
  }

  Widget _buildSummaryRow(String label, int value, Color color) {
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
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: color.withOpacity(0.1),
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
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
