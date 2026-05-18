import 'package:doctor_appointment/core/theme/app_theme_extension.dart';
import 'package:doctor_appointment/features/appointment/domain/entities/appointment.dart';
import 'package:doctor_appointment/features/appointment/logic/appointments_cubit.dart';
import 'package:doctor_appointment/features/appointment/logic/appointments_state.dart';
import 'package:doctor_appointment/features/calendar/presentation/widgets/appointment_card.dart';
import 'package:doctor_appointment/core/widgets/bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:skeletonizer/skeletonizer.dart';

class CalendarView extends StatefulWidget {
  const CalendarView({super.key});

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 0);
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
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Appointments',
          style: context.styleSemiBold22.copyWith(fontSize: 18.sp),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(44.h),
          child: TabBar(
            controller: _tabController,
            labelColor: colorScheme.primary,
            unselectedLabelColor: colorScheme.onSurfaceVariant,
            indicatorColor: colorScheme.primary,
            indicatorSize: TabBarIndicatorSize.label,
            labelStyle: context.styleMedium14.copyWith(fontSize: 13.sp),
            tabs: const [
              Tab(text: 'Upcoming'),
              Tab(text: 'Completed'),
              Tab(text: 'Cancelled'),
            ],
          ),
        ),
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification notification) {
          if (notification is OverscrollNotification &&
              notification.metrics.axis == Axis.horizontal) {
            final rootState = context.findAncestorStateOfType<RootState>();
            if (rootState != null) {
              if (notification.overscroll < 0 && _tabController.index == 0) {
                // Dragged to the right at the leftmost tab -> go to Search (Index 2)
                rootState.changePage(2);
              } else if (notification.overscroll > 0 && _tabController.index == 2) {
                // Dragged to the left at the rightmost tab -> go to Profile (Index 4)
                rootState.changePage(4);
              }
            }
          }
          return false;
        },
        child: LiquidPullToRefresh(
          onRefresh: () => context.read<AppointmentsCubit>().loadAppointments(),
          color: colorScheme.primary,
          backgroundColor: colorScheme.surface,
          showChildOpacityTransition: false,
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildList(AppointmentTab.upcoming),
              _buildList(AppointmentTab.completed),
              _buildList(AppointmentTab.cancelled),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildList(AppointmentTab tab) {
    final colorScheme = Theme.of(context).colorScheme;
    return BlocBuilder<AppointmentsCubit, AppointmentsState>(
      builder: (context, state) {
        if (state is AppointmentsLoading) {
          return Skeletonizer(
            enabled: true,
            child: ListView.separated(
              padding: EdgeInsets.only(
                left: 20.w,
                right: 20.w,
                top: 16.h,
                bottom: 100.h,
              ),
              itemCount: 5,
              separatorBuilder: (_, _) => SizedBox(height: 14.h),
              itemBuilder: (_, index) {
                // Mock appointment for skeleton
                return AppointmentCard(
                  appointment: Appointment(
                    id: 0,
                    patientId: 0,
                    patientName: '',
                    doctorId: 0,
                    doctorName: 'Doctor Name',
                    startTime: DateTime.now(),
                    endTime: DateTime.now(),
                    reason: '',
                    status: 1,
                    isPaid: false,
                    paymentMethod: 0,
                    paymentStatus: 0,
                    paymentTransactionId: '',
                    paymentDate: DateTime.now(),
                    amount: 0,
                    doctorNotes: '',
                    createdAt: DateTime.now(),
                  ),
                );
              },
            ),
          );
        }
        if (state is AppointmentsFailure) {
          return Center(
            child: Text(
              state.message,
              style: context.styleRegular14.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          );
        }
        if (state is AppointmentsSuccess) {
          final items = _filterAppointments(state.appointments, tab);
          if (items.isEmpty) {
            return Padding(
              padding: EdgeInsets.only(bottom: 100.h),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 64.sp,
                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.2),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'No appointments found.',
                      style: context.styleRegular14.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView.separated(
            padding: EdgeInsets.only(
              left: 20.w,
              right: 20.w,
              top: 16.h,
              bottom: 100.h,
            ),
            itemCount: items.length,
            separatorBuilder: (_, _) => SizedBox(height: 14.h),
            itemBuilder: (_, index) {
              return AppointmentCard(
                appointment: items[index],
                isCompleted: tab == AppointmentTab.completed,
                isCancelled: tab == AppointmentTab.cancelled,
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  List<Appointment> _filterAppointments(
    List<Appointment> appointments,
    AppointmentTab tab,
  ) {
    final now = DateTime.now();
    if (tab == AppointmentTab.cancelled) {
      return appointments.where((a) => a.status == 3).toList();
    }
    if (tab == AppointmentTab.completed) {
      return appointments
          .where((a) => a.status != 3 && a.endTime.isBefore(now))
          .toList();
    }
    // Upcoming: status != 3 and not passed
    return appointments
        .where((a) => a.status != 3 && !a.endTime.isBefore(now))
        .toList();
  }
}

enum AppointmentTab { upcoming, completed, cancelled }
