import 'package:doctor_appointment/core/utils/app_colors.dart';
import 'package:doctor_appointment/core/utils/app_styles.dart';
import 'package:doctor_appointment/features/doctors/logic/specializations_cubit.dart';
import 'package:doctor_appointment/features/doctors/logic/specializations_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DoctorSpecializationField extends StatefulWidget {
  final Set<String> selectedSpecializations;
  final VoidCallback onStateChanged;

  const DoctorSpecializationField({
    super.key,
    required this.selectedSpecializations,
    required this.onStateChanged,
  });

  @override
  State<DoctorSpecializationField> createState() =>
      _DoctorSpecializationFieldState();
}

class _DoctorSpecializationFieldState extends State<DoctorSpecializationField> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SpecializationsCubit, SpecializationsState>(
      builder: (context, state) {
        if (state is SpecializationsLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is SpecializationsFailure) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Specializations', style: AppStyles.styleMedium14),
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
                        'Failed to load specializations: ${state.message}',
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

        if (state is SpecializationsSuccess) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Specializations', style: AppStyles.styleMedium14),
              SizedBox(height: 8.h),
              Autocomplete<String>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text == '') {
                    return const Iterable<String>.empty();
                  }
                  return state.uniqueNames.where((String option) {
                    return option.toLowerCase().contains(
                      textEditingValue.text.toLowerCase(),
                    );
                  });
                },
                onSelected: (String selection) {
                  setState(() {
                    widget.selectedSpecializations.add(selection);
                    _controller.clear();
                  });
                  widget.onStateChanged();
                },
                fieldViewBuilder:
                    (context, controller, focusNode, onFieldSubmitted) {
                      return TextField(
                        controller: controller,
                        focusNode: focusNode,
                        decoration: InputDecoration(
                          hintText: 'Search specializations...',
                          prefixIcon: const Icon(Icons.search, size: 20),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide(color: Colors.grey[200]!),
                          ),
                        ),
                      );
                    },
              ),
              if (widget.selectedSpecializations.isNotEmpty) ...[
                SizedBox(height: 12.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: widget.selectedSpecializations.map((spec) {
                    return Chip(
                      label: Text(
                        spec,
                        style: AppStyles.styleRegular12.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      deleteIcon: const Icon(Icons.close, size: 14),
                      onDeleted: () {
                        setState(
                          () => widget.selectedSpecializations.remove(spec),
                        );
                        widget.onStateChanged();
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        side: BorderSide.none,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
