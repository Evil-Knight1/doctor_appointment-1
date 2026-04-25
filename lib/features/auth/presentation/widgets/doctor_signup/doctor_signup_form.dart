import 'package:doctor_appointment/core/utils/app_colors.dart';
import 'package:doctor_appointment/core/utils/app_styles.dart';
import 'package:doctor_appointment/features/auth/presentation/widgets/custom_text_field.dart';
import 'package:doctor_appointment/features/auth/presentation/widgets/doctor_signup/doctor_specialization_field.dart';
import 'package:doctor_appointment/features/doctors/domain/entities/specialization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phone_form_field/phone_form_field.dart';

class DoctorSignUpForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final VoidCallback onShowClinicLocationPicker;
  final VoidCallback onShowHospitalLocationPicker;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final TextEditingController yearsController;
  final TextEditingController licenseController;
  final TextEditingController bioController;
  final TextEditingController clinicAddressController;
  final TextEditingController hospitalController;
  final Specialization? selectedSpecialization;
  final ValueChanged<Specialization?> onSpecializationChanged;

  const DoctorSignUpForm({
    super.key,
    required this.formKey,
    required this.onShowClinicLocationPicker,
    required this.onShowHospitalLocationPicker,
    required this.nameController,
    required this.emailController,
    required this.phoneController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.yearsController,
    required this.licenseController,
    required this.bioController,
    required this.clinicAddressController,
    required this.hospitalController,
    required this.selectedSpecialization,
    required this.onSpecializationChanged,
  });

  @override
  State<DoctorSignUpForm> createState() => _DoctorSignUpFormState();
}

class _DoctorSignUpFormState extends State<DoctorSignUpForm> {
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmFocus = FocusNode();
  final FocusNode _yearsFocus = FocusNode();
  final FocusNode _licenseFocus = FocusNode();
  final FocusNode _hospitalFocus = FocusNode();

  @override
  void dispose() {
    _nameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    _yearsFocus.dispose();
    _licenseFocus.dispose();
    _hospitalFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Basic Information'),
        SizedBox(height: 16.h),
        _buildLabel('Full Name'),
        SizedBox(height: 8.h),
        CustomTextFormField(
          hintText: 'Dr. John Doe',
          controller: widget.nameController,
          focusNode: _nameFocus,
          textInputType: TextInputType.name,
        ),
        SizedBox(height: 16.h),
        _buildLabel('Email Address'),
        SizedBox(height: 8.h),
        CustomTextFormField(
          hintText: 'doctor@medlink.com',
          controller: widget.emailController,
          focusNode: _emailFocus,
          textInputType: TextInputType.emailAddress,
        ),
        SizedBox(height: 16.h),
        _buildLabel('Phone Number'),
        SizedBox(height: 8.h),
        PhoneFormField(
          key: const Key('phone-field'),
          decoration: InputDecoration(
            hintText: '1234567890',
            hintStyle: AppStyles.styleRegular14.copyWith(
              color: AppColors.textLight,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 16.h,
            ),
          ),
        ),
        SizedBox(height: 16.h),
        _buildLabel('Password'),
        SizedBox(height: 8.h),
        CustomTextFormField(
          hintText: '••••••••',
          controller: widget.passwordController,
          focusNode: _passwordFocus,
          isPassword: true,
        ),
        SizedBox(height: 16.h),
        _buildLabel('Confirm Password'),
        SizedBox(height: 8.h),
        CustomTextFormField(
          hintText: '••••••••',
          controller: widget.confirmPasswordController,
          focusNode: _confirmFocus,
          isPassword: true,
        ),

        SizedBox(height: 32.h),
        _buildSectionTitle('Professional Details'),
        SizedBox(height: 16.h),
        DoctorSpecializationField(
          selectedSpecialization: widget.selectedSpecialization,
          onChanged: widget.onSpecializationChanged,
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('Exp. Years'),
                  SizedBox(height: 8.h),
                  CustomTextFormField(
                    hintText: '5',
                    controller: widget.yearsController,
                    focusNode: _yearsFocus,
                    textInputType: TextInputType.number,
                  ),
                ],
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('License ID'),
                  SizedBox(height: 8.h),
                  CustomTextFormField(
                    hintText: 'LC-12345',
                    controller: widget.licenseController,
                    focusNode: _licenseFocus,
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        _buildLabel('Main Hospital'),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: widget.onShowHospitalLocationPicker,
          child: AbsorbPointer(
            child: CustomTextFormField(
              hintText: 'e.g. Cairo Specialist Hospital',
              controller: widget.hospitalController,
              focusNode: _hospitalFocus,
              suffixIcon: const Icon(
                Icons.map_rounded,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        SizedBox(height: 16.h),
        _buildLabel('Clinic Address'),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: widget.onShowClinicLocationPicker,
          child: AbsorbPointer(
            child: CustomTextFormField(
              hintText: 'Tap to select on map',
              controller: widget.clinicAddressController,
              suffixIcon: const Icon(
                Icons.map_rounded,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        SizedBox(height: 16.h),
        _buildLabel('Professional Bio'),
        SizedBox(height: 8.h),
        CustomTextFormField(
          hintText: 'Tell patients about your expertise...',
          controller: widget.bioController,
          textInputType: TextInputType.text,
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppStyles.styleSemiBold18.copyWith(color: AppColors.primary),
        ),
        SizedBox(height: 4.h),
        Container(
          width: 40.w,
          height: 3.h,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String label) {
    return Text(label, style: AppStyles.styleMedium14);
  }
}
