import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:doctor_appointment/core/utils/app_dimensions.dart';
import 'package:doctor_appointment/features/doctors/domain/entities/doctor.dart';
import 'package:doctor_appointment/core/utils/routes.dart';
import 'package:doctor_appointment/core/utils/app_styles.dart';
import '../widgets/booking_stepper.dart';
import '../widgets/shared_app_bar.dart';

class BookingDateView extends StatefulWidget {
  const BookingDateView({super.key, required this.doctor});
  final Doctor doctor;

  @override
  State<BookingDateView> createState() => _BookingDateViewState();
}

class _BookingDateViewState extends State<BookingDateView> {
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String? _selectedTime;

  final Map<String, List<String>> _categorizedTimeSlots = {
    'Morning': ['08:00 AM', '09:00 AM', '10:00 AM', '11:00 AM'],
    'Afternoon': ['12:00 PM', '01:00 PM', '02:00 PM', '03:00 PM', '04:00 PM'],
    'Evening': ['05:00 PM', '06:00 PM', '07:00 PM', '08:00 PM'],
  };

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: const SharedAppBar(title: 'Book Appointment'),
      body: Column(
        children: [
          const BookingStepper(currentStep: 0),
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(AppSpacing.lg),
              children: [
                Text('Select Date', style: context.headingMedium),
                SizedBox(height: AppSpacing.md),
                _CalendarPicker(
                  selectedDate: _selectedDate,
                  onDateSelected: (d) => setState(() => _selectedDate = d),
                ),
                SizedBox(height: AppSpacing.xl),
                Text('Select Time', style: context.headingMedium),
                SizedBox(height: AppSpacing.md),
                ..._categorizedTimeSlots.entries.map((entry) {
                  final category = entry.key;
                  final slots = entry.value;
                  return Padding(
                    padding: EdgeInsets.only(bottom: AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category,
                           style: context.labelLarge.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                        SizedBox(height: AppSpacing.sm),
                        Wrap(
                          spacing: AppSpacing.md,
                          runSpacing: AppSpacing.md,
                          children: slots.map((time) {
                            final isSelected = _selectedTime == time;
                            return GestureDetector(
                              onTap: () => setState(() => _selectedTime = time),
                              child: Container(
                                width: (1.sw - AppSpacing.lg * 2 - AppSpacing.md * 2) / 3,
                                padding: EdgeInsets.symmetric(vertical: 12.h),
                                decoration: BoxDecoration(
                                  color: isSelected ? colorScheme.primary : colorScheme.surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(AppRadius.lg),
                                  border: Border.all(
                                    color: isSelected ? colorScheme.primary : colorScheme.outlineVariant,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    time,
                                    style: context.bodySmall.copyWith(
                                      color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          _BottomAction(
            onNext: _selectedTime == null
                ? null
                : () => context.pushNamed(
                      Routes.bookingPaymentView,
                      extra: {
                        'doctor': widget.doctor,
                        'date': _selectedDate,
                        'time': _selectedTime,
                      },
                    ),
          ),
        ],
      ),
    );
  }
}

class _CalendarPicker extends StatelessWidget {
  const _CalendarPicker({
    required this.selectedDate,
    required this.onDateSelected,
  });

  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10.r,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TableCalendar(
        firstDay: DateTime.now(),
        lastDay: DateTime.now().add(const Duration(days: 90)),
        focusedDay: selectedDate,
        currentDay: DateTime.now(),
        selectedDayPredicate: (day) => isSameDay(selectedDate, day),
        onDaySelected: (selectedDay, focusedDay) {
          onDateSelected(selectedDay);
        },
        calendarFormat: CalendarFormat.month,
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: context.headingSmall,
          leftChevronIcon: Icon(Icons.chevron_left, color: colorScheme.primary),
          rightChevronIcon: Icon(Icons.chevron_right, color: colorScheme.primary),
        ),
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            shape: BoxShape.circle,
          ),
          todayTextStyle: TextStyle(color: colorScheme.onPrimaryContainer),
          selectedDecoration: BoxDecoration(
            color: colorScheme.primary,
            shape: BoxShape.circle,
          ),
          selectedTextStyle: TextStyle(color: colorScheme.onPrimary),
          outsideDaysVisible: false,
          defaultTextStyle: context.bodyMedium.copyWith(color: colorScheme.onSurface),
          weekendTextStyle: context.bodyMedium.copyWith(color: colorScheme.error),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: context.labelMedium,
          weekendStyle: context.labelMedium.copyWith(color: colorScheme.error),
        ),
      ),
    );
  }
}

class _BottomAction extends StatelessWidget {
  const _BottomAction({required this.onNext});
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.xl),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10.r,
            offset: Offset(0, -4.h),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 50.h,
        child: ElevatedButton(
          onPressed: onNext,
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            disabledBackgroundColor: colorScheme.outlineVariant,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
            elevation: 0,
          ),
          child: Text(
            'Next',
            style: TextStyle(color: colorScheme.onPrimary, fontWeight: FontWeight.w600, fontSize: 15.sp),
          ),
        ),
      ),
    );
  }
}
