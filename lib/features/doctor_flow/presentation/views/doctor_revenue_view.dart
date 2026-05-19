import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:doctor_appointment/core/theme/app_theme_extension.dart';
import 'package:doctor_appointment/features/doctor_flow/logic/doctor_revenue_cubit.dart';
import 'package:doctor_appointment/features/doctor_flow/logic/doctor_revenue_state.dart';

class DoctorRevenueView extends StatefulWidget {
  const DoctorRevenueView({super.key});

  @override
  State<DoctorRevenueView> createState() => _DoctorRevenueViewState();
}

class _DoctorRevenueViewState extends State<DoctorRevenueView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<DoctorRevenueCubit>().fetchRevenueData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: colorScheme.onSurface, size: 18.sp),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Financial Analytics',
          style: context.styleSemiBold18.copyWith(color: colorScheme.onSurface),
        ),
      ),
      body: BlocBuilder<DoctorRevenueCubit, DoctorRevenueState>(
        builder: (context, state) {
          if (state is DoctorRevenueLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is DoctorRevenueFailure) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(24.w),
                child: Text(
                  state.message,
                  style: context.styleMedium14.copyWith(color: colorScheme.error),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (state is DoctorRevenueSuccess) {
            final double totalMonthly = state.monthlyRevenues.fold(0.0, (sum, item) => sum + item.revenue);
            final int totalAppts = state.monthlyRevenues.fold(0, (sum, item) => sum + item.appointmentCount);

            return Column(
              children: [
                _buildSummaryBanner(context, totalMonthly, totalAppts),
                SizedBox(height: 12.h),
                _buildTabBar(context),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildMonthlyList(context, state),
                      _buildDailyList(context, state),
                    ],
                  ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildSummaryBanner(BuildContext context, double totalRevenue, int totalAppts) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: EdgeInsets.all(20.w),
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary,
            colorScheme.primary.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.25),
            blurRadius: 16.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Revenue (Yearly)',
                style: context.styleMedium12.copyWith(color: colorScheme.onPrimary.withValues(alpha: 0.7)),
              ),
              Icon(Icons.trending_up_rounded, color: colorScheme.onPrimary, size: 24.sp),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            '\$${totalRevenue.toStringAsFixed(2)}',
            style: context.styleBold32.copyWith(color: colorScheme.onPrimary, fontSize: 30.sp),
          ),
          SizedBox(height: 16.h),
          Divider(color: colorScheme.onPrimary.withValues(alpha: 0.15), height: 1),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Appointments',
                    style: context.styleMedium12.copyWith(color: colorScheme.onPrimary.withValues(alpha: 0.7)),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '$totalAppts Completed',
                    style: context.styleSemiBold14.copyWith(color: colorScheme.onPrimary),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Avg. Earning',
                    style: context.styleMedium12.copyWith(color: colorScheme.onPrimary.withValues(alpha: 0.7)),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '\$${(totalAppts > 0 ? totalRevenue / totalAppts : 0.0).toStringAsFixed(2)} / Visit',
                    style: context.styleSemiBold14.copyWith(color: colorScheme.onPrimary),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        height: 46.h,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: TabBar(
          controller: _tabController,
          indicatorSize: TabBarIndicatorSize.tab,
          indicator: BoxDecoration(
            color: colorScheme.primary,
            borderRadius: BorderRadius.circular(10.r),
          ),
          labelColor: colorScheme.onPrimary,
          unselectedLabelColor: colorScheme.onSurfaceVariant,
          labelStyle: context.styleBold14,
          unselectedLabelStyle: context.styleMedium14,
          tabs: const [
            Tab(text: 'Monthly Overview'),
            Tab(text: 'Daily Breakdowns'),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyList(BuildContext context, DoctorRevenueSuccess state) {
    final colorScheme = Theme.of(context).colorScheme;

    if (state.monthlyRevenues.isEmpty) {
      return Center(
        child: Text(
          'No monthly revenue history found.',
          style: context.styleMedium14.copyWith(color: colorScheme.onSurfaceVariant),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.all(20.w),
      itemCount: state.monthlyRevenues.length,
      separatorBuilder: (context, index) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        final item = state.monthlyRevenues[index];
        return Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.calendar_month_rounded, color: colorScheme.primary, size: 22.sp),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.monthName,
                      style: context.styleSemiBold16.copyWith(color: colorScheme.onSurface),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${item.appointmentCount} Appointments',
                      style: context.styleMedium12.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Text(
                '+\$${item.revenue.toStringAsFixed(2)}',
                style: context.styleBold16.copyWith(color: context.customColors.success),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDailyList(BuildContext context, DoctorRevenueSuccess state) {
    final colorScheme = Theme.of(context).colorScheme;

    if (state.dailyRevenues.isEmpty) {
      return Center(
        child: Text(
          'No daily revenue history found.',
          style: context.styleMedium14.copyWith(color: colorScheme.onSurfaceVariant),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.all(20.w),
      itemCount: state.dailyRevenues.length,
      separatorBuilder: (context, index) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        final item = state.dailyRevenues[index];
        return Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: context.customColors.success!.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.monetization_on_outlined, color: context.customColors.success, size: 22.sp),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('MMMM dd, yyyy').format(item.date),
                      style: context.styleSemiBold16.copyWith(color: colorScheme.onSurface),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${item.appointmentCount} Visits',
                      style: context.styleMedium12.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Text(
                '+\$${item.revenue.toStringAsFixed(2)}',
                style: context.styleBold16.copyWith(color: context.customColors.success),
              ),
            ],
          ),
        );
      },
    );
  }
}
