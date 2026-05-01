import 'package:doctor_appointment/core/utils/app_colors.dart';
import 'package:doctor_appointment/core/utils/app_styles.dart';
import 'package:doctor_appointment/features/auth/presentation/widgets/custom_text_field.dart';
import 'package:doctor_appointment/features/auth/presentation/widgets/doctor_signup/doctor_specialization_field.dart';
import 'package:doctor_appointment/features/auth/presentation/widgets/registration_date_picker.dart';
import 'package:doctor_appointment/features/auth/presentation/widgets/registration_dropdown.dart';
import 'package:doctor_appointment/features/auth/presentation/widgets/registration_text_field.dart';
import 'package:doctor_appointment/features/doctors/domain/entities/specialization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phone_form_field/phone_form_field.dart';
import 'package:doctor_appointment/core/widgets/image_picker_widget.dart';

class DoctorSignUpForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final int step;
  final VoidCallback onShowClinicLocationPicker;
  final VoidCallback onShowHospitalLocationPicker;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final PhoneController phoneController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final TextEditingController yearsController;
  final TextEditingController licenseController;
  final TextEditingController bioController;
  final TextEditingController clinicAddressController;
  final TextEditingController hospitalController;
  final Specialization? selectedSpecialization;
  final ValueChanged<Specialization?> onSpecializationChanged;
  final DateTime? selectedDateOfBirth;
  final ValueChanged<DateTime?> onDateOfBirthChanged;
  final String? selectedGender;
  final ValueChanged<String?> onGenderChanged;

  /// Per-field server validation errors keyed by lowercase field name
  final Map<String, String> fieldErrors;

  const DoctorSignUpForm({
    super.key,
    required this.formKey,
    required this.step,
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
    required this.profilePicturePath,
    required this.onProfilePictureChanged,
    required this.clinicImagesPaths,
    required this.onClinicImagesChanged,
    required this.selectedDateOfBirth,
    required this.onDateOfBirthChanged,
    required this.selectedGender,
    required this.onGenderChanged,
    this.fieldErrors = const {},
  });

  final String? profilePicturePath;
  final ValueChanged<String?> onProfilePictureChanged;
  final List<String> clinicImagesPaths;
  final ValueChanged<List<String>> onClinicImagesChanged;

  @override
  State<DoctorSignUpForm> createState() => _DoctorSignUpFormState();
}

class _DoctorSignUpFormState extends State<DoctorSignUpForm> {
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmFocus = FocusNode();

  final FocusNode _nameFocus = FocusNode();
  final FocusNode _yearsFocus = FocusNode();
  final FocusNode _licenseFocus = FocusNode();
  final FocusNode _bioFocus = FocusNode();

  final FocusNode _hospitalFocus = FocusNode();
  final FocusNode _clinicFocus = FocusNode();

  @override
  void dispose() {
    _emailFocus.dispose();
    _phoneFocus.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    _nameFocus.dispose();
    _yearsFocus.dispose();
    _licenseFocus.dispose();
    _bioFocus.dispose();
    _hospitalFocus.dispose();
    _clinicFocus.dispose();
    super.dispose();
  }

  /// Returns the server error message for a given field key, or null.
  String? _serverError(String key) => widget.fieldErrors[key.toLowerCase()];

  @override
  Widget build(BuildContext context) {
    switch (widget.step) {
      case 1:
        return _buildStep1();
      case 2:
        return _buildStep2();
      case 3:
        return _buildStep3();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildStep1() {
    return Column(
      children: [
        RegistrationTextField(
          label: 'Email Address',
          hintText: 'example@doctor.com',
          controller: widget.emailController,
          focusNode: _emailFocus,
          keyboardType: TextInputType.emailAddress,
          prefixIcon: Icons.email_outlined,
          serverError: _serverError('email'),
        ),
        SizedBox(height: 16.h),
        _buildPhoneField(),
        SizedBox(height: 16.h),
        RegistrationTextField(
          label: 'Password',
          hintText: '••••••••',
          controller: widget.passwordController,
          focusNode: _passwordFocus,
          isPassword: true,
          prefixIcon: Icons.lock_outline_rounded,
          serverError: _serverError('password'),
        ),
        SizedBox(height: 16.h),
        RegistrationTextField(
          label: 'Confirm Password',
          hintText: '••••••••',
          controller: widget.confirmPasswordController,
          focusNode: _confirmFocus,
          isPassword: true,
          prefixIcon: Icons.lock_reset_rounded,
          serverError: _serverError('confirmpassword'),
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      children: [
        ProfileImagePicker(
          imagePath: widget.profilePicturePath,
          onImageSelected: widget.onProfilePictureChanged,
        ),
        SizedBox(height: 24.h),
        RegistrationTextField(
          label: 'Full Name',
          hintText: 'Dr. John Doe',
          controller: widget.nameController,
          focusNode: _nameFocus,
          prefixIcon: Icons.person_outline_rounded,
          serverError: _serverError('fullname') ?? _serverError('fullName'),
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
              child: RegistrationDatePicker(
                label: 'Birth Date',
                selectedDate: widget.selectedDateOfBirth,
                onDateSelected: widget.onDateOfBirthChanged,
                hintText: 'MM/DD/YYYY',
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: RegistrationDropdown(
                label: 'Gender',
                value: widget.selectedGender,
                items: const [
                  DropdownMenuItem(value: 'Male', child: Text('Male')),
                  DropdownMenuItem(value: 'Female', child: Text('Female')),
                ],
                onChanged: widget.onGenderChanged,
                hintText: 'Select Gender',
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        RegistrationTextField(
          label: 'License ID',
          hintText: 'e.g. LIC-123456',
          controller: widget.licenseController,
          focusNode: _licenseFocus,
          prefixIcon: Icons.badge_outlined,
          serverError:
              _serverError('licensenumber') ?? _serverError('licenseid'),
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
              child: RegistrationTextField(
                label: 'Exp. Years',
                hintText: '5',
                controller: widget.yearsController,
                focusNode: _yearsFocus,
                keyboardType: TextInputType.number,
                serverError:
                    _serverError('yearsofexperience') ??
                    _serverError('experienceyears'),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: DoctorSpecializationField(
                selectedSpecialization: widget.selectedSpecialization,
                onChanged: widget.onSpecializationChanged,
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        RegistrationTextField(
          label: 'Professional Bio',
          hintText: 'Tell patients about your expertise...',
          controller: widget.bioController,
          focusNode: _bioFocus,
          maxLines: 3,
          serverError: _serverError('bio'),
        ),
      ],
    );
  }

  Widget _buildStep3() {
    return Column(
      children: [
        MultiImagePicker(
          imagePaths: widget.clinicImagesPaths,
          onImagesSelected: widget.onClinicImagesChanged,
        ),
        SizedBox(height: 24.h),
        RegistrationTextField(
          label: 'Main Hospital',
          hintText: 'e.g. Cairo Specialist Hospital',
          controller: widget.hospitalController,
          focusNode: _hospitalFocus,
          prefixIcon: Icons.local_hospital_outlined,
          suffixIcon: IconButton(
            icon: const Icon(Icons.map_rounded, color: AppColors.primary),
            onPressed: widget.onShowHospitalLocationPicker,
          ),
          serverError: _serverError('hospital'),
        ),
        SizedBox(height: 16.h),
        RegistrationTextField(
          label: 'Clinic Address',
          hintText: 'Tap map icon to select',
          controller: widget.clinicAddressController,
          focusNode: _clinicFocus,
          prefixIcon: Icons.location_on_outlined,
          suffixIcon: IconButton(
            icon: const Icon(Icons.map_rounded, color: AppColors.primary),
            onPressed: widget.onShowClinicLocationPicker,
          ),
          serverError: _serverError('clinicaddress'),
        ),
      ],
    );
  }

  Widget _buildPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: 'Phone Number',
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
        PhoneFormField(
          key: const Key('phone-field'),
          controller: widget.phoneController,
          focusNode: _phoneFocus,
          decoration: InputDecoration(
            hintText: '1234567890',
            hintStyle: AppStyles.styleRegular14.copyWith(
              color: const Color(0xFF949D9E),
            ),
            errorText: _serverError('phone'),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 14.h,
            ),
            border: _buildBorder(const Color(0xFFE2E8F0)),
            enabledBorder: _buildBorder(const Color(0xFFE2E8F0)),
            focusedBorder: _buildBorder(const Color(0xff236DEC), width: 1.5),
            errorBorder: _buildBorder(const Color(0xFFEF4444)),
            focusedErrorBorder: _buildBorder(
              const Color(0xFFEF4444),
              width: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  OutlineInputBorder _buildBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.r),
      borderSide: BorderSide(width: width, color: color),
    );
  }
}
