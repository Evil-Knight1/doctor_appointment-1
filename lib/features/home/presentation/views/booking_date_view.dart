import 'package:doctor_appointment/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:doctor_appointment/core/utils/app_dimensions.dart';
import 'package:doctor_appointment/features/doctors/domain/entities/doctor.dart';
import 'package:doctor_appointment/core/utils/routes.dart';
import 'package:doctor_appointment/features/appointment/logic/doctor_slots_cubit.dart';
import 'package:doctor_appointment/features/appointment/logic/doctor_slots_state.dart';
import 'package:doctor_appointment/features/appointment/data/models/slot_model.dart';

import '../widgets/booking_stepper.dart';
import '../widgets/shared_app_bar.dart';
import 'package:doctor_appointment/core/theme/app_theme_extension.dart';
import 'package:skeletonizer/skeletonizer.dart';


class BookingDateView extends StatefulWidget {
  const BookingDateView({
    super.key,
    required this.doctor,
    this.rescheduleAppointmentId,
  });
  final Doctor doctor;
  final int? rescheduleAppointmentId;

  @override
  State<BookingDateView> createState() => _BookingDateViewState();
}

class _BookingDateViewState extends State<BookingDateView> {
  DateTime _selectedDate = DateTime.now();
  SlotModel? _selectedSlot;
  int _selectedType = 0; // 0 = Regular Visit, 1 = Consultation

  @override
  void initState() {
    super.initState();
    // Fetch slots for today on initial load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DoctorSlotsCubit>().fetchSlots(
        widget.doctor.id,
        _selectedDate,
      );
    });
  }

  Map<String, List<SlotModel>> _groupSlots(List<SlotModel> slots) {
    final Map<String, List<SlotModel>> categorized = {
      'Morning': [],
      'Afternoon': [],
      'Evening': [],
    };

    for (var slot in slots) {
      final hour = slot.startTime.hour;
      if (hour < 12) {
        categorized['Morning']!.add(slot);
      } else if (hour < 17) {
        categorized['Afternoon']!.add(slot);
      } else {
        categorized['Evening']!.add(slot);
      }
    }

    return categorized;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: SharedAppBar(
        title: AppLocalizations.of(context)!.bookAppointment,
      ),
      body: Column(
        children: [
          const BookingStepper(currentStep: 0),
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(AppSpacing.lg),
              children: [
                Text(
                  AppLocalizations.of(context)!.selectDate,
                  style: context.headingMedium,
                ),
                SizedBox(height: AppSpacing.md),
                BlocBuilder<DoctorSlotsCubit, DoctorSlotsState>(
                  builder: (context, state) {
                    final List<SlotModel> allSlots = state is DoctorSlotsLoaded
                        ? state.slots
                        : [];

                    return _CalendarPicker(
                      selectedDate: _selectedDate,
                      slots: allSlots,
                      onDateSelected: (d) {
                        setState(() {
                          _selectedDate = d;
                          _selectedSlot = null;
                        });
                        // Re-fetch slots for the newly selected date
                        context.read<DoctorSlotsCubit>().fetchSlots(
                          widget.doctor.id,
                          d,
                        );
                      },
                    );
                  },
                ),
                SizedBox(height: AppSpacing.xl),
                Text(
                  AppLocalizations.of(context)!.selectTime,
                  style: context.headingMedium,
                ),
                SizedBox(height: AppSpacing.md),
                BlocBuilder<DoctorSlotsCubit, DoctorSlotsState>(
                  builder: (context, state) {
                    if (state is DoctorSlotsLoading) {
                      return _buildLoadingSlots();
                    } else if (state is DoctorSlotsError) {
                      return _buildErrorState(state.message);
                    } else if (state is DoctorSlotsLoaded) {
                      if (state.slots.isEmpty) {
                        return _buildGlobalNoSlotsAvailable();
                      }

                      final categorized = _groupSlots(state.slots);
                      final hasAnySlots = categorized.values.any(
                        (list) => list.isNotEmpty,
                      );

                      if (!hasAnySlots) {
                        return _buildNoSlotsAvailable();
                      }

                      return Column(
                        children: categorized.entries.map((entry) {
                          final category = entry.key;
                          final slots = entry.value;
                          if (slots.isEmpty) return const SizedBox.shrink();

                          return Padding(
                            padding: EdgeInsets.only(bottom: AppSpacing.lg),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  category,
                                  style: context.labelLarge.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                SizedBox(height: AppSpacing.sm),
                                Wrap(
                                  spacing: AppSpacing.md,
                                  runSpacing: AppSpacing.md,
                                  children: slots.map((slot) {
                                    final isSelected =
                                        _selectedSlot?.id == slot.id;
                                    final timeStr = DateFormat(
                                      'hh:mm a',
                                    ).format(slot.startTime);
                                    final isSlotAvailable =
                                        slot.isAvailable && !slot.isBooked;

                                    return GestureDetector(
                                      onTap: isSlotAvailable
                                          ? () => setState(
                                              () => _selectedSlot = slot,
                                            )
                                          : null,
                                      child: Container(
                                        width:
                                            (1.sw -
                                                AppSpacing.lg * 2 -
                                                AppSpacing.md * 2) /
                                            3,
                                        padding: EdgeInsets.symmetric(
                                          vertical: 12.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? colorScheme.primary
                                              : (isSlotAvailable
                                                    ? colorScheme
                                                          .surfaceContainerLow
                                                    : colorScheme
                                                          .surfaceContainerLow
                                                          .withValues(
                                                            alpha: 0.4,
                                                          )),
                                          borderRadius: BorderRadius.circular(
                                            AppRadius.lg,
                                          ),
                                          border: Border.all(
                                            color: isSelected
                                                ? colorScheme.primary
                                                : (isSlotAvailable
                                                      ? colorScheme
                                                            .outlineVariant
                                                      : colorScheme
                                                            .outlineVariant
                                                            .withValues(
                                                              alpha: 0.4,
                                                            )),
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            timeStr,
                                            style: context.bodySmall.copyWith(
                                              color: isSelected
                                                  ? colorScheme.onPrimary
                                                  : (isSlotAvailable
                                                        ? colorScheme.onSurface
                                                        : colorScheme
                                                              .onSurfaceVariant
                                                              .withValues(
                                                                alpha: 0.4,
                                                              )),
                                              fontWeight: isSelected
                                                  ? FontWeight.w600
                                                  : FontWeight.w400,
                                              decoration: isSlotAvailable
                                                  ? null
                                                  : TextDecoration.lineThrough,
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
                        }).toList(),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                SizedBox(height: AppSpacing.xl),
                Text(
                  AppLocalizations.of(context)!.appointmentType,
                  style: context.headingMedium,
                ),
                SizedBox(height: AppSpacing.md),
                _buildAppointmentTypeSelector(),
              ],
            ),
          ),
          _BottomAction(
            onNext: _selectedSlot == null
                ? null
                : () {
                    final args = {
                      'doctor': widget.doctor,
                      'date': _selectedDate,
                      'time': DateFormat(
                        'hh:mm a',
                      ).format(_selectedSlot!.startTime),
                      'slotId': _selectedSlot!.id,
                      'amount': widget.doctor.consultationPrice ?? 100.0,
                      'type': _selectedType,
                    };

                    if (widget.rescheduleAppointmentId != null) {
                      args['rescheduleAppointmentId'] =
                          widget.rescheduleAppointmentId!;
                      context.pushNamed(Routes.bookingSummaryView, extra: args);
                    } else {
                      context.pushNamed(Routes.bookingPaymentView, extra: args);
                    }
                  },
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingSlots() {
    return Skeletonizer(
      enabled: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: 80.w, height: 20.h, color: Colors.white),
          SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: List.generate(
              6,
              (index) => Container(
                width: (1.sw - AppSpacing.lg * 2 - AppSpacing.md * 2) / 3,
                height: 45.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlobalNoSlotsAvailable() {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: AppSpacing.xxl,
        horizontal: AppSpacing.xl,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: colorScheme.errorContainer.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.event_busy_rounded,
              size: 48.sp,
              color: colorScheme.error.withValues(alpha: 0.7),
            ),
          ),
          SizedBox(height: AppSpacing.lg),
          Text(
            'Doctor has no availability',
            style: context.headingSmall.copyWith(fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            'This doctor hasn\'t set any slots yet.\nPlease check back later or choose another doctor.',
            style: context.bodySmall.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNoSlotsAvailable() {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 40.sp,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            'No slots for this date',
            style: context.bodyLarge.copyWith(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 4.h),
          Text(
            'Try selecting a date marked with a dot',
            style: context.bodySmall.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        children: [
          Icon(Icons.error_outline, color: colorScheme.error, size: 40.sp),
          SizedBox(height: AppSpacing.sm),
          Text(message, style: context.bodyMedium),
          TextButton(
            onPressed: () => context.read<DoctorSlotsCubit>().fetchSlots(
              widget.doctor.id,
              _selectedDate,
            ),
            child: Text(AppLocalizations.of(context)!.retry),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentTypeSelector() {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(
          child: _TypeSelectionCard(
            title: l10n.regularVisit,
            subtitle: l10n.regularVisitSubtitle,
            icon: Icons.favorite_border_rounded,
            isSelected: _selectedType == 0,
            onTap: () => setState(() => _selectedType = 0),
          ),
        ),
        SizedBox(width: AppSpacing.md),
        Expanded(
          child: _TypeSelectionCard(
            title: l10n.consultation,
            subtitle: l10n.consultationSubtitle,
            icon: Icons.chat_bubble_outline_rounded,
            isSelected: _selectedType == 1,
            onTap: () => setState(() => _selectedType = 1),
          ),
        ),
      ],
    );
  }
}

class _TypeSelectionCard extends StatelessWidget {
  const _TypeSelectionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primaryContainer.withValues(alpha: 0.15)
              : colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.08),
                    blurRadius: 12.r,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  icon,
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                  size: 24.sp,
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle_rounded,
                    color: colorScheme.primary,
                    size: 20.sp,
                  ),
              ],
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              title,
              style: context.bodyMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: isSelected ? colorScheme.primary : colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              subtitle,
              style: context.bodySmall.copyWith(
                fontSize: 10.sp,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CalendarPicker extends StatelessWidget {
  const _CalendarPicker({
    required this.selectedDate,
    required this.onDateSelected,
    required this.slots,
  });

  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final List<SlotModel> slots;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Get unique days that have slots
    final availableDays = slots
        .map(
          (s) => DateTime(s.startTime.year, s.startTime.month, s.startTime.day),
        )
        .toSet();

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
        enabledDayPredicate: (day) {
          // Only allow selecting days that are today or in the future
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);
          return !day.isBefore(today);
        },
        onDaySelected: (selectedDay, focusedDay) {
          onDateSelected(selectedDay);
        },
        calendarFormat: CalendarFormat.month,
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: context.headingSmall,
          leftChevronIcon: Icon(Icons.chevron_left, color: colorScheme.primary),
          rightChevronIcon: Icon(
            Icons.chevron_right,
            color: colorScheme.primary,
          ),
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
          defaultTextStyle: context.bodyMedium.copyWith(
            color: colorScheme.onSurface,
          ),
          weekendTextStyle: context.bodyMedium.copyWith(
            color: colorScheme.error,
          ),
          // Custom marker for available slots
          markersMaxCount: 1,
          markerDecoration: BoxDecoration(
            color: colorScheme.secondary,
            shape: BoxShape.circle,
          ),
        ),
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, date, events) {
            final day = DateTime(date.year, date.month, date.day);
            if (availableDays.contains(day)) {
              return Positioned(
                bottom: 1,
                child: Container(
                  width: 5.r,
                  height: 5.r,
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              );
            }
            return null;
          },
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
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.xl,
      ),
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            elevation: 0,
          ),
          child: Text(
            AppLocalizations.of(context)!.next,
            style: TextStyle(
              color: colorScheme.onPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 15.sp,
            ),
          ),
        ),
      ),
    );
  }
}
