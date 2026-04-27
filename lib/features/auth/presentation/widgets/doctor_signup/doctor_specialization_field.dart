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
              Text('Specialization', style: AppStyles.styleMedium14),
              SizedBox(height: 8.h),
              DropdownButtonFormField<Specialization>(
                initialValue: widget.selectedSpecialization,
                isExpanded: true,
                decoration: InputDecoration(
                  hintText: 'Select your specialization',
                  hintStyle: AppStyles.styleRegular14.copyWith(
                    color: Colors.grey[400],
                  ),
                  prefixIcon: const Icon(
                    Icons.medical_services_outlined,
                    size: 20,
                    color: AppColors.primary,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: Colors.grey[200]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: Colors.grey[200]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 1.5,
                    ),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 14.h,
                  ),
                ),
                items: items.map((spec) {
                  return DropdownMenuItem<Specialization>(
                    value: spec,
                    child: Container(
                      color: Colors.blueAccent.withAlpha(50),
                      padding: .symmetric(horizontal: 12.w, vertical: 4.h),
                      child: Text(
                        spec.name,
                        style: AppStyles.styleRegular14,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: widget.onChanged,
                validator: (value) =>
                    value == null ? 'Please select a specialization' : null,
              ),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
