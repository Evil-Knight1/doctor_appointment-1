import 'package:doctor_appointment/core/utils/app_colors.dart';
import 'package:doctor_appointment/core/utils/app_images.dart';
import 'package:doctor_appointment/core/utils/app_styles.dart';
import 'package:doctor_appointment/core/services/service_locator.dart';
import 'package:doctor_appointment/features/appointment/domain/entities/appointment.dart';
import 'package:doctor_appointment/features/appointment/logic/appointments_cubit.dart';
import 'package:doctor_appointment/features/appointment/logic/appointments_state.dart';
import 'package:doctor_appointment/features/calendar/presentation/widgets/appointment_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CalendarView extends StatefulWidget {
  const CalendarView({super.key});

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late final AppointmentsCubit _appointmentsCubit;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 0);
    _appointmentsCubit = getIt<AppointmentsCubit>();
    _appointmentsCubit.loadAppointments();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _appointmentsCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _appointmentsCubit,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Text(
            'Appointments',
            style: AppStyles.styleSemiBold22.copyWith(fontSize: 18.sp),
          ),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(44.h),
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primary,
              indicatorSize: TabBarIndicatorSize.label,
              labelStyle: AppStyles.styleMedium14.copyWith(fontSize: 13.sp),
              tabs: const [
                Tab(text: 'Upcoming'),
                Tab(text: 'Completed'),
                Tab(text: 'Cancelled'),
              ],
            ),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildList(AppointmentTab.upcoming),
            _buildList(AppointmentTab.completed),
            _buildList(AppointmentTab.cancelled),
          ],
        ),
      ),
    );
  }

  Widget _buildList(AppointmentTab tab) {
    return BlocBuilder<AppointmentsCubit, AppointmentsState>(
      builder: (context, state) {
        if (state is AppointmentsLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is AppointmentsFailure) {
          return Center(
            child: Text(
              state.message,
              style: AppStyles.styleRegular14.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          );
        }
        if (state is AppointmentsSuccess) {
          final items = _filterAppointments(state.appointments, tab);
          if (items.isEmpty) {
            return Center(
              child: Text(
                'No appointments found.',
                style: AppStyles.styleRegular14.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            );
          }
          return ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            itemCount: items.length,
            separatorBuilder: (_, _) => SizedBox(height: 14.h),
            itemBuilder: (_, index) {
              final card = _mapToCard(items[index], tab);
              return AppointmentCard(
                name: card.name,
                specialty: card.specialty,
                date: card.date,
                time: card.time,
                imageAsset: card.imageAsset,
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
    if (tab == AppointmentTab.completed) {
      return appointments.where((a) => a.endTime.isBefore(now)).toList();
    }
    if (tab == AppointmentTab.cancelled) {
      return appointments.where((a) => a.status == 3).toList();
    }
    return appointments.where((a) => !a.endTime.isBefore(now)).toList();
  }

  _AppointmentCardData _mapToCard(Appointment appointment, AppointmentTab tab) {
    final images = [
      Assets.imagesDrAyeshaRahman,
      Assets.imagesDrSarah,
      Assets.imagesDrNobleThorme,
    ];
    final image = images[appointment.doctorId % images.length];
    return _AppointmentCardData(
      name: appointment.doctorName,
      specialty: 'Doctor',
      date: _formatDate(appointment.startTime),
      time: _formatTime(appointment.startTime),
      imageAsset: image,
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class _AppointmentCardData {
  final String name;
  final String specialty;
  final String date;
  final String time;
  final String imageAsset;

  const _AppointmentCardData({
    required this.name,
    required this.specialty,
    required this.date,
    required this.time,
    required this.imageAsset,
  });
}

enum AppointmentTab { upcoming, completed, cancelled }
