import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:doctor_appointment/core/theme/app_theme_extension.dart';
import 'package:doctor_appointment/features/doctor_flow/logic/doctor_availability_cubit.dart';
import 'package:doctor_appointment/features/doctor_flow/logic/doctor_availability_state.dart';
import 'package:doctor_appointment/features/doctors/data/models/availability_model.dart';

class DoctorAvailabilityView extends StatefulWidget {
  final int doctorId;
  const DoctorAvailabilityView({super.key, required this.doctorId});

  @override
  State<DoctorAvailabilityView> createState() => _DoctorAvailabilityViewState();
}

class _DoctorAvailabilityViewState extends State<DoctorAvailabilityView> {
  @override
  void initState() {
    super.initState();
    context.read<DoctorAvailabilityCubit>().fetchAvailability(widget.doctorId);
  }

  final List<String> _daysOfWeek = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
  ];

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
          'Working Hours & Slots',
          style: context.styleSemiBold18.copyWith(color: colorScheme.onSurface),
        ),
      ),
      body: BlocConsumer<DoctorAvailabilityCubit, DoctorAvailabilityState>(
        listener: (context, state) {
          if (state is DoctorAvailabilityFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is DoctorAvailabilityLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final availabilities = state is DoctorAvailabilitySuccess
              ? state.availabilities
              : <AvailabilityModel>[];

          return ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            itemCount: 7,
            separatorBuilder: (context, index) => SizedBox(height: 12.h),
            itemBuilder: (context, index) {
              // DayOfWeek: 0 = Sunday, 1 = Monday ... 6 = Saturday
              final existing = availabilities.firstWhere(
                (element) => element.dayOfWeek == index,
                orElse: () => const AvailabilityModel(
                  id: -1,
                  dayOfWeek: -1,
                  startTime: '',
                  endTime: '',
                  isAvailable: false,
                ),
              );

              final isConfigured = existing.id != -1;

              return _buildDayTile(context, index, existing, isConfigured);
            },
          );
        },
      ),
    );
  }

  Widget _buildDayTile(
    BuildContext context,
    int dayIndex,
    AvailabilityModel availability,
    bool isConfigured,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final isAvailable = isConfigured && availability.isAvailable;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isAvailable
            ? colorScheme.primary.withValues(alpha: 0.04)
            : colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isAvailable
              ? colorScheme.primary.withValues(alpha: 0.3)
              : colorScheme.outlineVariant.withValues(alpha: 0.4),
          width: 1.5.w,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _daysOfWeek[dayIndex],
                  style: context.styleSemiBold16.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 8.h),
                if (isAvailable)
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: colorScheme.outlineVariant),
                    ),
                    child: Text(
                      availability.timeRange,
                      style: context.bodySmall.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                else
                  Text(
                    'Unavailable / Off-duty',
                    style: context.styleMedium14.copyWith(
                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                    ),
                  ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _showConfigureBottomSheet(context, dayIndex, availability, isConfigured),
            style: ElevatedButton.styleFrom(
              backgroundColor: isAvailable
                  ? colorScheme.primary
                  : colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
              foregroundColor: isAvailable
                  ? colorScheme.onPrimary
                  : colorScheme.onSurfaceVariant,
              elevation: 0,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: Text(
              isConfigured ? 'Edit' : 'Configure',
              style: context.styleMedium12.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showConfigureBottomSheet(
    BuildContext context,
    int dayOfWeek,
    AvailabilityModel availability,
    bool isConfigured,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    
    TimeOfDay startTime = const TimeOfDay(hour: 9, minute: 0);
    TimeOfDay endTime = const TimeOfDay(hour: 17, minute: 0);
    int duration = 30;
    
    final priceController = TextEditingController(text: '50');
    final consPriceController = TextEditingController(text: '30');

    if (isConfigured && availability.startTime.isNotEmpty) {
      final startParts = availability.startTime.split(':');
      if (startParts.length >= 2) {
        startTime = TimeOfDay(
          hour: int.tryParse(startParts[0]) ?? 9,
          minute: int.tryParse(startParts[1]) ?? 0,
        );
      }
      final endParts = availability.endTime.split(':');
      if (endParts.length >= 2) {
        endTime = TimeOfDay(
          hour: int.tryParse(endParts[0]) ?? 17,
          minute: int.tryParse(endParts[1]) ?? 0,
        );
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (stContext, setState) {
            String formatTime(TimeOfDay tod) {
              final hour = tod.hour.toString().padLeft(2, '0');
              final minute = tod.minute.toString().padLeft(2, '0');
              return '$hour:$minute';
            }

            return Padding(
              padding: EdgeInsets.only(
                left: 20.w,
                right: 20.w,
                top: 24.h,
                bottom: MediaQuery.of(stContext).viewInsets.bottom + 24.h,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 48.w,
                        height: 5.h,
                        decoration: BoxDecoration(
                          color: colorScheme.outlineVariant,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      'Configure ${_daysOfWeek[dayOfWeek]}',
                      style: context.styleSemiBold18.copyWith(color: colorScheme.onSurface),
                    ),
                    SizedBox(height: 20.h),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final picked = await showTimePicker(
                                context: stContext,
                                initialTime: startTime,
                              );
                              if (picked != null) {
                                setState(() => startTime = picked);
                              }
                            },
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(16.r),
                                border: Border.all(color: colorScheme.outlineVariant),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Start Time',
                                    style: context.styleMedium12.copyWith(color: colorScheme.onSurfaceVariant),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    startTime.format(stContext),
                                    style: context.bodySmall.copyWith(
                                      color: colorScheme.onSurface,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final picked = await showTimePicker(
                                context: stContext,
                                initialTime: endTime,
                              );
                              if (picked != null) {
                                setState(() => endTime = picked);
                              }
                            },
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(16.r),
                                border: Border.all(color: colorScheme.outlineVariant),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'End Time',
                                    style: context.styleMedium12.copyWith(color: colorScheme.onSurfaceVariant),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    endTime.format(stContext),
                                    style: context.bodySmall.copyWith(
                                      color: colorScheme.onSurface,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      'Slot Duration',
                      style: context.styleSemiBold14.copyWith(color: colorScheme.onSurface),
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [15, 30, 45, 60].map((dur) {
                        final selected = duration == dur;
                        return ChoiceChip(
                          label: Text('$dur min'),
                          selected: selected,
                          selectedColor: colorScheme.primary,
                          labelStyle: context.styleMedium12.copyWith(
                            fontWeight: FontWeight.bold,
                            color: selected ? colorScheme.onPrimary : colorScheme.onSurface,
                          ),
                          onSelected: (_) {
                            setState(() => duration = dur);
                          },
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 20.h),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: priceController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              labelText: 'Regular Price (\$)',
                              labelStyle: context.styleMedium14,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: TextField(
                            controller: consPriceController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              labelText: 'Consultation Price (\$)',
                              labelStyle: context.styleMedium14,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 32.h),
                    SizedBox(
                      width: double.infinity,
                      height: 52.h,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                        ),
                        onPressed: () async {
                          final pStr = priceController.text.trim();
                          final cpStr = consPriceController.text.trim();
                          final price = double.tryParse(pStr) ?? 50.0;
                          final cp = double.tryParse(cpStr) ?? 30.0;

                          final cubit = context.read<DoctorAvailabilityCubit>();
                          Navigator.pop(stContext);

                          bool ok;
                          if (isConfigured) {
                            ok = await cubit.updateAvailability(
                              doctorId: widget.doctorId,
                              availabilityId: availability.id,
                              startTime: '${formatTime(startTime)}:00',
                              endTime: '${formatTime(endTime)}:00',
                              durationMinutes: duration,
                              price: price,
                              consultationPrice: cp,
                            );
                          } else {
                            ok = await cubit.addAvailability(
                              doctorId: widget.doctorId,
                              dayOfWeek: dayOfWeek,
                              startTime: '${formatTime(startTime)}:00',
                              endTime: '${formatTime(endTime)}:00',
                              durationMinutes: duration,
                              price: price,
                              consultationPrice: cp,
                            );
                          }

                          if (stContext.mounted && ok) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Availability for ${_daysOfWeek[dayOfWeek]} saved!'),
                                backgroundColor: colorScheme.primary,
                              ),
                            );
                          }
                        },
                        child: Text(
                          'Save Availability',
                          style: context.styleBold16.copyWith(color: colorScheme.onPrimary),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
