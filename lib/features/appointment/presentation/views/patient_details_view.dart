import 'package:doctor_appointment/core/utils/app_colors.dart';
import 'package:doctor_appointment/core/utils/app_styles.dart';
import 'package:doctor_appointment/core/services/service_locator.dart';
import 'package:doctor_appointment/features/appointment/logic/appointment_cubit.dart';
import 'package:doctor_appointment/features/appointment/logic/appointment_state.dart';
import 'package:doctor_appointment/features/appointment/presentation/models/appointment_draft.dart';
import 'package:doctor_appointment/features/appointment/presentation/widgets/patient_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class PatientDetailsView extends StatefulWidget {
  final AppointmentDraft draft;

  const PatientDetailsView({super.key, required this.draft});

  @override
  State<PatientDetailsView> createState() => _PatientDetailsViewState();
}

class _PatientDetailsViewState extends State<PatientDetailsView> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _ageController = TextEditingController();
  final _detailController = TextEditingController();
  String? _selectedGender;
  late final AppointmentCubit _appointmentCubit;

  @override
  void initState() {
    super.initState();
    _appointmentCubit = getIt<AppointmentCubit>();
  }

  @override
  void dispose() {
    _appointmentCubit.close();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    _detailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _appointmentCubit,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              margin: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: AppColors.bg,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16.sp,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          title: Text(
            "Patient's details",
            style: AppStyles.styleSemiBold22.copyWith(fontSize: 18.sp),
          ),
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 8.h),
                  PatientFormField(
                    label: 'Full Name',
                    hint: 'John',
                    controller: _nameController,
                  ),
                  PatientFormField(
                    label: 'Email',
                    hint: 'example@email.com',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  PatientFormField(
                    label: 'Phone number',
                    hint: '+1 234 567 8900',
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                  ),
                  _buildGenderField(),
                  PatientFormField(
                    label: 'Age',
                    hint: 'Enter your age',
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                  ),
                  PatientFormField(
                    label: 'Detail',
                    hint: 'Enter your detail here...',
                    controller: _detailController,
                    maxLines: 4,
                  ),
                  SizedBox(height: 100.h),
                ],
              ),
            ),
            _buildBottomButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gender',
          style: AppStyles.styleMedium14.copyWith(fontSize: 13.sp),
        ),
        SizedBox(height: 6.h),
        Container(
          height: 46.h,
          padding: EdgeInsets.symmetric(horizontal: 14.w),
          decoration: BoxDecoration(
            color: AppColors.bg,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedGender,
              hint: Text(
                'Select your gender',
                style: AppStyles.styleRegular14.copyWith(
                  color: AppColors.textLight,
                  fontSize: 12.sp,
                ),
              ),
              isExpanded: true,
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.textSecondary,
              ),
              onChanged: (v) => setState(() => _selectedGender = v),
              items: ['Male', 'Female', 'Other']
                  .map(
                    (g) => DropdownMenuItem(
                      value: g,
                      child: Text(g, style: AppStyles.styleMedium14),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
        SizedBox(height: 14.h),
      ],
    );
  }

  Widget _buildBottomButton(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 32.h),
        color: Colors.white,
        child: BlocConsumer<AppointmentCubit, AppointmentState>(
          listener: (context, state) {
            if (state is AppointmentFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
            if (state is AppointmentSuccess) {
              context.push('/appointmentSuccess');
            }
          },
          builder: (context, state) {
            final isLoading = state is AppointmentLoading;
            return ElevatedButton(
              onPressed: isLoading ? null : () => _submit(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
                minimumSize: Size(double.infinity, 52.h),
                elevation: 0,
              ),
              child: Text(
                isLoading ? 'Booking...' : 'Book Appointment',
                style: AppStyles.styleSemiBold16,
              ),
            );
          },
        ),
      ),
    );
  }

  void _submit(BuildContext context) {
    final reason = _detailController.text.trim().isEmpty
        ? 'General consultation'
        : _detailController.text.trim();

    final startTime = _buildStartTime(widget.draft.date, widget.draft.time);
    final endTime = startTime.add(const Duration(minutes: 30));

    context.read<AppointmentCubit>().createAppointment(
          doctorId: widget.draft.doctor.id,
          startTime: startTime,
          endTime: endTime,
          reason: reason,
        );
  }

  DateTime _buildStartTime(DateTime date, String time) {
    final parts = time.split(':');
    final hour = parts.isNotEmpty ? int.tryParse(parts[0]) ?? 0 : 0;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    return DateTime(date.year, date.month, date.day, hour, minute);
  }
}
