import 'package:doctor_appointment/core/theme/app_theme_extension.dart';

import 'package:doctor_appointment/features/home/data/models/home_doctor_model.dart';
import 'package:doctor_appointment/features/appointment/presentation/models/appointment_draft.dart';
import 'package:doctor_appointment/core/utils/go_router.dart';
import 'package:doctor_appointment/features/appointment/presentation/widgets/date_picker_widget.dart';
import 'package:doctor_appointment/features/appointment/presentation/widgets/consultation_type_widget.dart';
import 'package:doctor_appointment/features/appointment/presentation/widgets/available_time_widget.dart';
import 'package:doctor_appointment/features/appointment/presentation/widgets/consultation_fees_widget.dart';
import 'package:doctor_appointment/features/appointment/data/models/slot_model.dart';
import 'package:doctor_appointment/features/appointment/logic/doctor_slots_cubit.dart';
import 'package:doctor_appointment/features/appointment/logic/doctor_slots_state.dart';
import 'package:doctor_appointment/core/services/service_locator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class NewAppointmentView extends StatefulWidget {
  final HomeDoctorModel doctor;
  const NewAppointmentView({super.key, required this.doctor});

  @override
  State<NewAppointmentView> createState() => _NewAppointmentViewState();
}

class _NewAppointmentViewState extends State<NewAppointmentView> {
  late DoctorSlotsCubit _slotsCubit;
  DateTime _selectedDate = DateTime.now();
  String _selectedConsultation = 'Clinic';
  SlotModel? _selectedSlot;

  /// All slots returned by the API (across all dates).
  List<SlotModel> _allSlots = [];

  /// Dates that have at least one available slot — used to mark the calendar.
  Set<DateTime> get _availableDates {
    return _allSlots
        .where((s) => s.isAvailable && !s.isBooked)
        .map((s) => DateUtils.dateOnly(s.startTime))
        .toSet();
  }

  /// Slots that belong to [_selectedDate] and are still available.
  List<SlotModel> get _slotsForSelectedDate {
    return _allSlots
        .where(
          (s) =>
              DateUtils.isSameDay(s.startTime, _selectedDate) &&
              s.isAvailable &&
              !s.isBooked,
        )
        .toList();
  }

  /// The next 60 days — dates with no slots will appear dimmed in the picker.
  List<DateTime> get _weekDays {
    final start = DateTime.now();
    return List.generate(60, (i) => start.add(Duration(days: i)));
  }

  @override
  void initState() {
    super.initState();
    _slotsCubit = getIt<DoctorSlotsCubit>();
    // Fetch slots for today's date
    _slotsCubit.fetchSlots(widget.doctor.doctor.id, DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: Container(
            margin: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 16.sp,
              color: colorScheme.onSurface,
            ),
          ),
        ),
        title: Text(
          'New Appointment',
          style: context.styleSemiBold22.copyWith(
            fontSize: 18.sp,
            color: colorScheme.onSurface,
          ),
        ),
      ),
      body: BlocProvider(
        create: (context) => _slotsCubit,
        child: BlocConsumer<DoctorSlotsCubit, DoctorSlotsState>(
          listener: (context, state) {
            if (state is DoctorSlotsLoaded) {
              setState(() {
                _allSlots = state.slots;
                _selectedSlot = null;
                // Auto-jump to first date that has slots, if today has none.
                if (_slotsForSelectedDate.isEmpty &&
                    _availableDates.isNotEmpty) {
                  final sorted = _availableDates.toList()..sort();
                  _selectedDate = sorted.first;
                }
              });
            }
          },
          builder: (context, state) {
            if (state is DoctorSlotsLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is DoctorSlotsError) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(24.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline_rounded, size: 64.sp, color: colorScheme.error),
                      SizedBox(height: 16.h),
                      Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: context.styleMedium14.copyWith(color: colorScheme.error),
                      ),
                      SizedBox(height: 24.h),
                      ElevatedButton(
                        onPressed: () => _slotsCubit.fetchSlots(
                          widget.doctor.doctor.id,
                          DateTime.now(),
                        ),
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state is DoctorSlotsLoaded && _availableDates.isEmpty) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(24.w),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.calendar_today_outlined,
                          size: 64.sp,
                          color: colorScheme.primary,
                        ),
                      ),
                      SizedBox(height: 24.h),
                      Text(
                        'No Availability Found',
                        style: context.styleSemiBold22.copyWith(fontSize: 20.sp),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        'This doctor hasn\'t set any available slots yet. Please check back later or try another doctor.',
                        textAlign: TextAlign.center,
                        style: context.styleRegular14.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          height: 1.5,
                        ),
                      ),
                      SizedBox(height: 32.h),
                      OutlinedButton(
                        onPressed: () => context.pop(),
                        style: OutlinedButton.styleFrom(
                          minimumSize: Size(200.w, 48.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: const Text('Go Back'),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Stack(
              children: [
                SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 16.h),
                      DatePickerWidget(
                        selectedDate: _selectedDate,
                        weekDays: _weekDays,
                        availableDates: _availableDates,
                        onDateSelected: (d) {
                          setState(() {
                            _selectedDate = d;
                            _selectedSlot = null;
                          });
                        },
                      ),
                      SizedBox(height: 24.h),
                      _sectionTitle('Consultation Type', colorScheme, Icons.medical_services_outlined),
                      SizedBox(height: 16.h),
                      ConsultationTypeWidget(
                        selected: _selectedConsultation,
                        onSelected: (t) =>
                            setState(() => _selectedConsultation = t),
                      ),
                      SizedBox(height: 32.h),
                      _sectionTitle('Available Slots', colorScheme, Icons.access_time_rounded),
                      SizedBox(height: 16.h),
                      AvailableTimeWidget(
                        slots: _slotsForSelectedDate,
                        selectedSlot: _selectedSlot,
                        onSlotSelected: (s) =>
                            setState(() => _selectedSlot = s),
                      ),
                      SizedBox(height: 32.h),
                      _sectionTitle('Consultation Fees', colorScheme, Icons.payments_outlined),
                      SizedBox(height: 16.h),
                      ConsultationFeesWidget(
                        fee: widget.doctor.doctor.consultationFee ?? 0.0,
                        selectedType: _selectedConsultation,
                      ),
                      SizedBox(height: 140.h),
                    ],
                  ),
                ),
                _buildBottomButton(context),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, ColorScheme colorScheme, IconData icon) => Row(
    children: [
      Icon(icon, size: 20.sp, color: colorScheme.primary),
      SizedBox(width: 8.w),
      Text(
        title,
        style: context.styleSemiBold22.copyWith(
          fontSize: 16.sp,
          color: colorScheme.onSurface,
        ),
      ),
    ],
  );

  Widget _buildBottomButton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 32.h),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _selectedSlot == null
              ? null
              : () {
                  final baseFee = widget.doctor.doctor.consultationFee ?? 0.0;
                  final amount = _selectedConsultation == 'Home visit' ? baseFee * 1.5 : baseFee;
                  
                  final draft = AppointmentDraft(
                    doctor: widget.doctor,
                    date: _selectedDate,
                    slot: _selectedSlot!,
                    consultationType: _selectedConsultation,
                    amount: amount,
                  );
                  context.push(AppRouter.kPatientDetails, extra: draft);
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            disabledBackgroundColor: colorScheme.outlineVariant,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14.r),
            ),
            minimumSize: Size(double.infinity, 52.h),
            elevation: 0,
          ),
          child: Text(
            'Book Appointment',
            style: context.styleSemiBold16.copyWith(
              color: _selectedSlot == null
                  ? colorScheme.onSurfaceVariant
                  : colorScheme.onPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
