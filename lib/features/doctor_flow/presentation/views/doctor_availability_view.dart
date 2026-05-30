import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:doctor_appointment/core/theme/app_theme_extension.dart';
import 'package:doctor_appointment/features/doctor_flow/logic/doctor_availability_cubit.dart';
import 'package:doctor_appointment/features/doctor_flow/logic/doctor_availability_state.dart';
import 'package:doctor_appointment/features/doctors/data/models/availability_model.dart';
import 'package:doctor_appointment/l10n/app_localizations.dart';

class DoctorAvailabilityView extends StatefulWidget {
  final int doctorId;
  const DoctorAvailabilityView({super.key, required this.doctorId});

  @override
  State<DoctorAvailabilityView> createState() => _DoctorAvailabilityViewState();
}

class _DoctorAvailabilityViewState extends State<DoctorAvailabilityView> {
  int _selectedDateIndex = 0;
  late List<DateTime> _dates;

  final _fromController = TextEditingController();
  final _toController = TextEditingController();
  final _durationController = TextEditingController(text: '30');
  final _consultationController = TextEditingController(text: '30');
  final _appointmentController = TextEditingController(text: '50');

  List<AvailabilityModel> _availabilities = [];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    // Generate 7 days starting from today
    _dates = List.generate(7, (index) => now.add(Duration(days: index)));
    context.read<DoctorAvailabilityCubit>().fetchAvailability(widget.doctorId);
  }

  void _populateFields() {
    if (_availabilities.isEmpty) return;

    final selectedDate = _dates[_selectedDateIndex];
    final backendDay = selectedDate.weekday == 7 ? 0 : selectedDate.weekday;

    final existing = _availabilities.firstWhere(
      (element) => element.dayOfWeek == backendDay,
      orElse: () => const AvailabilityModel(
        id: -1,
        dayOfWeek: -1,
        startTime: '',
        endTime: '',
        isAvailable: false,
      ),
    );

    if (existing.id != -1 &&
        existing.startTime.isNotEmpty &&
        existing.endTime.isNotEmpty) {
      _fromController.text = existing.startTime.substring(0, 5);
      _toController.text = existing.endTime.substring(0, 5);
    } else {
      _fromController.text = '';
      _toController.text = '';
    }
  }

  Future<void> _pickTime(TextEditingController controller) async {
    TimeOfDay initialTime = TimeOfDay.now();
    if (controller.text.isNotEmpty) {
      final parts = controller.text.split(':');
      if (parts.length >= 2) {
        initialTime = TimeOfDay(
          hour: int.tryParse(parts[0]) ?? 0,
          minute: int.tryParse(parts[1]) ?? 0,
        );
      }
    }

    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (picked != null && mounted) {
      final hour = picked.hour.toString().padLeft(2, '0');
      final minute = picked.minute.toString().padLeft(2, '0');
      setState(() {
        controller.text = '$hour:$minute';
      });
    }
  }

  Future<void> _onGenerate() async {
    final from = _fromController.text.trim();
    final to = _toController.text.trim();
    final durationStr = _durationController.text.trim();
    final consStr = _consultationController.text.trim();
    final apptStr = _appointmentController.text.trim();

    if (from.isEmpty ||
        to.isEmpty ||
        durationStr.isEmpty ||
        consStr.isEmpty ||
        apptStr.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.pleaseFillAllFields)));
      return;
    }

    final duration = int.tryParse(durationStr) ?? 30;
    final consPrice = double.tryParse(consStr) ?? 30.0;
    final apptPrice = double.tryParse(apptStr) ?? 50.0;

    final selectedDate = _dates[_selectedDateIndex];
    final backendDay = selectedDate.weekday == 7 ? 0 : selectedDate.weekday;

    final existing = _availabilities.firstWhere(
      (element) => element.dayOfWeek == backendDay,
      orElse: () => const AvailabilityModel(
        id: -1,
        dayOfWeek: -1,
        startTime: '',
        endTime: '',
        isAvailable: false,
      ),
    );

    final cubit = context.read<DoctorAvailabilityCubit>();
    bool success;
    if (existing.id != -1) {
      success = await cubit.updateAvailability(
        doctorId: widget.doctorId,
        availabilityId: existing.id,
        startTime: '$from:00',
        endTime: '$to:00',
        durationMinutes: duration,
        price: apptPrice,
        consultationPrice: consPrice,
      );
    } else {
      success = await cubit.addAvailability(
        doctorId: widget.doctorId,
        dayOfWeek: backendDay,
        startTime: '$from:00',
        endTime: '$to:00',
        durationMinutes: duration,
        price: apptPrice,
        consultationPrice: consPrice,
      );
    }

    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.availabilityGeneratedSuccessfully),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          margin: EdgeInsets.all(16),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: colorScheme.onSurface,
            size: 18.sp,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppLocalizations.of(context)!.availableTime,
          style: context.styleSemiBold18.copyWith(color: colorScheme.onSurface),
        ),
      ),
      body: BlocConsumer<DoctorAvailabilityCubit, DoctorAvailabilityState>(
        listener: (context, state) {
          if (state is DoctorAvailabilitySuccess) {
            _availabilities = state.availabilities;
            _populateFields();
          } else if (state is DoctorAvailabilityFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is DoctorAvailabilityLoading && _availabilities.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.selectDateLabel,
                  style: context.styleSemiBold16.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Icon(
                      Icons.arrow_back_ios_rounded,
                      size: 16.sp,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _dates.asMap().entries.map((entry) {
                            final idx = entry.key;
                            final date = entry.value;
                            final isSelected = idx == _selectedDateIndex;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedDateIndex = idx;
                                  _populateFields();
                                });
                              },
                              child: Container(
                                margin: EdgeInsets.symmetric(horizontal: 6.w),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 12.h,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? colorScheme.primary
                                      : colorScheme.surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(16.r),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      DateFormat('EEE').format(date),
                                      style: context.styleMedium14.copyWith(
                                        color: isSelected
                                            ? colorScheme.onPrimary
                                            : colorScheme.onSurfaceVariant
                                                  .withValues(alpha: .5),
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      DateFormat('dd').format(date),
                                      style: context.styleSemiBold16.copyWith(
                                        color: isSelected
                                            ? colorScheme.onPrimary
                                            : colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16.sp,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
                SizedBox(height: 32.h),
                Text(
                  AppLocalizations.of(context)!.availableTimeLabel,
                  style: context.styleSemiBold16.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Expanded(
                      child: _CustomInputField(
                        hintText: AppLocalizations.of(context)!.fromTime,
                        controller: _fromController,
                        onTap: () => _pickTime(_fromController),
                        isReadOnly: true,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: _CustomInputField(
                        hintText: AppLocalizations.of(context)!.toTime,
                        controller: _toController,
                        onTap: () => _pickTime(_toController),
                        isReadOnly: true,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Text(
                  AppLocalizations.of(context)!.duration,
                  style: context.styleSemiBold16.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 16.h),
                _CustomInputField(
                  hintText: '15 min',
                  controller: _durationController,
                ),
                SizedBox(height: 32.h),
                Text(
                  AppLocalizations.of(context)!.fees,
                  style: context.styleSemiBold16.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.consultation,
                            style: context.styleMedium14.copyWith(
                              color: colorScheme.onSurface.withValues(
                                alpha: .5,
                              ),
                            ),
                          ),
                          SizedBox(height: 16.h),
                          _CustomInputField(
                            hintText: '100 ${AppLocalizations.of(context)!.egpSuffix}',
                            controller: _consultationController,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.appointment,
                            style: context.styleMedium14.copyWith(
                              color: colorScheme.onSurface.withValues(
                                alpha: .5,
                              ),
                            ),
                          ),
                          SizedBox(height: 16.h),
                          _CustomInputField(
                            hintText: '50 ${AppLocalizations.of(context)!.egpSuffix}',
                            controller: _appointmentController,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 48.h),
                SizedBox(
                  width: double.infinity,
                  height: 54.h,
                  child: ElevatedButton(
                    onPressed: _onGenerate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.generate,
                      style: context.styleBold16.copyWith(
                        color: colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 32.h),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CustomInputField extends StatefulWidget {
  final String hintText;
  final TextEditingController? controller;
  final VoidCallback? onTap;
  final bool isReadOnly;

  const _CustomInputField({
    required this.hintText,
    this.controller,
    this.onTap,
    this.isReadOnly = false,
  });

  @override
  State<_CustomInputField> createState() => _CustomInputFieldState();
}

class _CustomInputFieldState extends State<_CustomInputField> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        height: 52.h,
        clipBehavior: Clip.antiAlias,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            if (_isFocused)
              BoxShadow(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.15),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
          ],
        ),
        child: widget.isReadOnly
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.controller?.text.isNotEmpty == true
                        ? widget.controller!.text
                        : widget.hintText,
                    style: context.styleMedium14.copyWith(
                      color: widget.controller?.text.isNotEmpty == true
                          ? Theme.of(context).colorScheme.onSurface
                          : Theme.of(context).colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.5),
                    ),
                  ),
                ],
              )
            : SizedBox(
                width: double.infinity,
                child: TextField(
                  focusNode: _focusNode,
                  expands: true,
                  maxLines: null,
                  minLines: null,
                  textAlignVertical: TextAlignVertical.center,
                  controller: widget.controller,
                  textAlign: TextAlign.center,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    hintText: widget.hintText,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                    hintStyle: context.styleMedium14.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurfaceVariant.withValues(alpha: .5),
                    ),
                  ),
                  style: context.styleMedium14.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
      ),
    );
  }
}
