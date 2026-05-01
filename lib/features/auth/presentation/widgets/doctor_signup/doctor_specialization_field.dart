import 'package:doctor_appointment/core/utils/app_colors.dart';
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
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SpecializationsCubit, SpecializationsState>(
      builder: (context, state) {
        // --- Loading ---
        if (state is SpecializationsLoading) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Specialization', style: AppStyles.styleMedium14),
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
              Text('Specialization', style: AppStyles.styleMedium14),
              SizedBox(height: 8.h),
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.red[100]!),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        'Failed to load: ${state.message}',
                        style: AppStyles.styleRegular12.copyWith(
                          color: Colors.red[700],
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.red),
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
                  style: AppStyles.styleMedium14,
                  children: [
                    TextSpan(
                      text: ' *',
                      style: AppStyles.styleMedium14.copyWith(
                        color: const Color(0xFFEF4444),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8.h),
              DropdownButtonFormField<Specialization>(
                value: widget.selectedSpecialization,
                isExpanded: true,
                icon: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: const Color(0xFF949D9E),
                  size: 20.sp,
                ),
                decoration: InputDecoration(
                  hintText: 'Select Specialization',
                  hintStyle: AppStyles.styleRegular14.copyWith(
                    color: const Color(0xFF949D9E),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF9FAFB),
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(left: 14.w, right: 10.w),
                    child: Icon(
                      Icons.medical_services_outlined,
                      size: 20.sp,
                      color: const Color(0xFF949D9E),
                    ),
                  ),
                  prefixIconConstraints: BoxConstraints(
                    minWidth: 44.w,
                    minHeight: 20.h,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 14.h,
                  ),
                  border: _buildBorder(const Color(0xFFE2E8F0)),
                  enabledBorder: _buildBorder(const Color(0xFFE2E8F0)),
                  focusedBorder: _buildBorder(
                    const Color(0xff236DEC),
                    width: 1.5,
                  ),
                  errorBorder: _buildBorder(const Color(0xFFEF4444)),
                  focusedErrorBorder: _buildBorder(
                    const Color(0xFFEF4444),
                    width: 1.5,
                  ),
                ),
                items: items.map((spec) {
                  return DropdownMenuItem<Specialization>(
                    value: spec,
                    child: Text(
                      spec.name,
                      style: AppStyles.styleMedium14.copyWith(
                        color: const Color(0xff1E252D),
                      ),
                    ),
                  );
                }).toList(),
                onChanged: widget.onChanged,
                validator: (value) =>
                    value == null ? 'Specialization is required' : null,
              ),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  InputBorder? _buildBorder(Color color, {double width = 1.0}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.r),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
