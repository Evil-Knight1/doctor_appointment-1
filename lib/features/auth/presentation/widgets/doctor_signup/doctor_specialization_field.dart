import 'package:doctor_appointment/core/utils/app_styles.dart';
import 'package:doctor_appointment/features/doctors/domain/entities/specialization.dart';
import 'package:doctor_appointment/features/doctors/logic/specializations_cubit.dart';
import 'package:doctor_appointment/features/doctors/logic/specializations_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A single-select specialization dropdown backed by the live API.
/// Exposes [selectedSpecialization] (the full entity) and calls
/// [onChanged] whenever the user picks a different item.
class DoctorSpecializationField extends StatefulWidget {
  final Specialization? selectedSpecialization;
  final ValueChanged<Specialization?> onChanged;

  const DoctorSpecializationField({
    super.key,
    required this.selectedSpecialization,
    required this.onChanged,
  });

  @override
  State<DoctorSpecializationField> createState() =>
      _DoctorSpecializationFieldState();
}

class _DoctorSpecializationFieldState extends State<DoctorSpecializationField> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return BlocBuilder<SpecializationsCubit, SpecializationsState>(
      builder: (context, state) {
        // --- Loading ---
        if (state is SpecializationsLoading) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Specialization',
                style: AppStyles.styleMedium14.copyWith(
                  color: theme.textTheme.headlineLarge?.color,
                ),
              ),
              SizedBox(height: 8.h),
              const Center(child: CircularProgressIndicator()),
            ],
          );
        }

        // --- Error ---
        if (state is SpecializationsFailure) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Specialization',
                style: AppStyles.styleMedium14.copyWith(
                  color: theme.textTheme.headlineLarge?.color,
                ),
              ),
              SizedBox(height: 8.h),
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: theme.colorScheme.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: theme.colorScheme.error.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: theme.colorScheme.error),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        'Failed to load: ${state.message}',
                        style: AppStyles.styleRegular12.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.refresh, color: theme.colorScheme.error),
                      onPressed: () => context
                          .read<SpecializationsCubit>()
                          .fetchSpecializations(),
                    ),
                  ],
                ),
              ),
            ],
          );
        }

        // --- Success ---
        if (state is SpecializationsSuccess) {
          final items = state.specializations;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  text: 'Specialization',
                  style: AppStyles.styleMedium14.copyWith(
                    color: _isFocused
                        ? theme.colorScheme.primary
                        : theme.textTheme.headlineLarge?.color,
                  ),
                  children: [
                    TextSpan(
                      text: ' *',
                      style: AppStyles.styleMedium14.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8.h),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: _isFocused
                      ? [
                          BoxShadow(
                            color: theme.colorScheme.primary.withValues(alpha: 0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [],
                ),
                child: DropdownButtonFormField<Specialization>(
                  initialValue: widget.selectedSpecialization,
                  isExpanded: true,
                  focusNode: _focusNode,
                  icon: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: _isFocused
                        ? theme.colorScheme.primary
                        : theme.hintColor,
                    size: 22.sp,
                  ),
                  dropdownColor: theme.cardColor,
                  style: AppStyles.styleMedium14.copyWith(
                    color: theme.textTheme.headlineLarge?.color,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Select Specialization',
                    prefixIcon: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: EdgeInsets.only(left: 14.w, right: 10.w),
                      child: Icon(
                        Icons.medical_services_outlined,
                        size: 20.sp,
                        color: _isFocused
                            ? theme.colorScheme.primary
                            : theme.hintColor,
                      ),
                    ),
                    prefixIconConstraints: BoxConstraints(
                      minWidth: 44.w,
                      minHeight: 20.h,
                    ),
                  ),
                  items: items.map((spec) {
                    return DropdownMenuItem<Specialization>(
                      value: spec,
                      child: Text(
                        spec.name,
                        style: AppStyles.styleMedium14.copyWith(
                          color: theme.textTheme.headlineLarge?.color,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: widget.onChanged,
                  validator: (value) =>
                      value == null ? 'Specialization is required' : null,
                ),
              ),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

