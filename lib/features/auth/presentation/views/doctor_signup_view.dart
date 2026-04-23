import 'package:doctor_appointment/core/utils/app_styles.dart';
import 'package:doctor_appointment/core/utils/go_router.dart';
import 'package:doctor_appointment/features/auth/presentation/widgets/form_section_header.dart';
import 'package:doctor_appointment/features/auth/presentation/widgets/registration_dropdown.dart';
import 'package:doctor_appointment/features/auth/presentation/widgets/registration_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

/// Standalone doctor registration view.
/// Since the backend does not yet have a doctor-register endpoint, this form
/// collects all professional fields and navigates to the pending-approval
/// screen on submission — matching the existing behaviour.
class DoctorSignUpView extends StatefulWidget {
  const DoctorSignUpView({super.key});

  @override
  State<DoctorSignUpView> createState() => _DoctorSignUpViewState();
}

class _DoctorSignUpViewState extends State<DoctorSignUpView> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  // --- Controllers ---
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _yearsController = TextEditingController();
  final _licenseController = TextEditingController();
  final _bioController = TextEditingController();
  final _clinicAddressController = TextEditingController();
  final _hospitalController = TextEditingController();

  // --- Focus Nodes ---
  final _emailFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();
  final _yearsFocus = FocusNode();
  final _licenseFocus = FocusNode();
  final _bioFocus = FocusNode();
  final _clinicAddressFocus = FocusNode();
  final _hospitalFocus = FocusNode();

  // --- Dropdown values ---
  String? _selectedSpecialization;

  static const _specializations = [
    {'id': '1', 'name': 'General Practice'},
    {'id': '2', 'name': 'Cardiology'},
    {'id': '3', 'name': 'Dermatology'},
    {'id': '4', 'name': 'Pediatrics'},
    {'id': '5', 'name': 'Orthopedics'},
    {'id': '6', 'name': 'Neurology'},
    {'id': '7', 'name': 'Psychiatry'},
    {'id': '8', 'name': 'Ophthalmology'},
    {'id': '9', 'name': 'ENT'},
    {'id': '10', 'name': 'Dentistry'},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _yearsController.dispose();
    _licenseController.dispose();
    _bioController.dispose();
    _clinicAddressController.dispose();
    _hospitalController.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    _yearsFocus.dispose();
    _licenseFocus.dispose();
    _bioFocus.dispose();
    _clinicAddressFocus.dispose();
    _hospitalFocus.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() != true) return;

    if (_passwordController.text.trim() !=
        _confirmPasswordController.text.trim()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Passwords do not match'),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    // Navigate to pending approval (existing behaviour for doctors)
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() => _isSubmitting = false);
        context.push(AppRouter.kDoctorPendingApprovalView);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: CustomScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              sliver: SliverToBoxAdapter(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20.h),

                      // --- Back button ---
                      _BackButton(onTap: () => context.pop()),
                      SizedBox(height: 20.h),

                      // --- Header ---
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Doctor\nRegistration',
                                  style: AppStyles.styleSemiBold24,
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  'Join our network of healthcare professionals.',
                                  style: AppStyles.styleRegular14.copyWith(
                                    color: const Color(0xFF949D9E),
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Container(
                            width: 56.w,
                            height: 56.h,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xff236DEC),
                                  const Color(0xff236DEC).withValues(alpha: 0.7),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            child: Icon(
                              Icons.medical_services_rounded,
                              color: Colors.white,
                              size: 28.sp,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20.h),

                      // --- Approval Notice ---
                      _ApprovalNotice(),
                      SizedBox(height: 28.h),

                      // ========================
                      // SECTION 1: Basic Info
                      // ========================
                      const FormSectionHeader(
                        title: 'Basic Information',
                        icon: Icons.person_outline_rounded,
                        subtitle: 'Your account credentials',
                      ),

                      RegistrationTextField(
                        label: 'Full Name',
                        hintText: 'Dr. John Doe',
                        controller: _nameController,
                        keyboardType: TextInputType.name,
                        prefixIcon: Icons.person_outline_rounded,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) =>
                            FocusScope.of(context).requestFocus(_emailFocus),
                      ),
                      SizedBox(height: 16.h),

                      RegistrationTextField(
                        label: 'Email',
                        hintText: 'doctor@hospital.com',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.email_outlined,
                        focusNode: _emailFocus,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) =>
                            FocusScope.of(context).requestFocus(_phoneFocus),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Email is required';
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                              .hasMatch(value.trim())) {
                            return 'Enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16.h),

                      RegistrationTextField(
                        label: 'Phone Number',
                        hintText: '+216 XX XXX XXX',
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        prefixIcon: Icons.phone_outlined,
                        focusNode: _phoneFocus,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) =>
                            FocusScope.of(context).requestFocus(_passwordFocus),
                      ),
                      SizedBox(height: 16.h),

                      RegistrationTextField(
                        label: 'Password',
                        hintText: 'Min. 6 characters',
                        controller: _passwordController,
                        isPassword: true,
                        prefixIcon: Icons.lock_outline_rounded,
                        focusNode: _passwordFocus,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) => FocusScope.of(context)
                            .requestFocus(_confirmPasswordFocus),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Password is required';
                          }
                          if (value.trim().length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16.h),

                      RegistrationTextField(
                        label: 'Confirm Password',
                        hintText: 'Re-enter your password',
                        controller: _confirmPasswordController,
                        isPassword: true,
                        prefixIcon: Icons.lock_outline_rounded,
                        focusNode: _confirmPasswordFocus,
                        textInputAction: TextInputAction.done,
                      ),
                      SizedBox(height: 28.h),

                      // ========================
                      // SECTION 2: Professional Info
                      // ========================
                      const FormSectionHeader(
                        title: 'Professional Information',
                        icon: Icons.work_outline_rounded,
                        subtitle: 'Your medical expertise',
                      ),

                      RegistrationDropdown<String>(
                        label: 'Specialization',
                        hintText: 'Select your specialization',
                        value: _selectedSpecialization,
                        prefixIcon: Icons.local_hospital_outlined,
                        items: _specializations
                            .map(
                              (s) => DropdownMenuItem<String>(
                                value: s['id'],
                                child: Text(s['name']!),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() => _selectedSpecialization = value);
                        },
                      ),
                      SizedBox(height: 16.h),

                      RegistrationTextField(
                        label: 'Years of Experience',
                        hintText: 'e.g. 5',
                        controller: _yearsController,
                        keyboardType: TextInputType.number,
                        prefixIcon: Icons.timeline_outlined,
                        focusNode: _yearsFocus,
                        textInputAction: TextInputAction.next,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(2),
                        ],
                        onFieldSubmitted: (_) =>
                            FocusScope.of(context).requestFocus(_licenseFocus),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Years of experience is required';
                          }
                          final years = int.tryParse(value.trim());
                          if (years == null || years < 0) {
                            return 'Enter a valid number';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16.h),

                      RegistrationTextField(
                        label: 'Bio',
                        hintText: 'Tell patients about yourself...',
                        controller: _bioController,
                        keyboardType: TextInputType.multiline,
                        prefixIcon: Icons.description_outlined,
                        isRequired: false,
                        maxLines: 3,
                        focusNode: _bioFocus,
                        textInputAction: TextInputAction.newline,
                      ),
                      SizedBox(height: 28.h),

                      // ========================
                      // SECTION 3: Verification
                      // ========================
                      const FormSectionHeader(
                        title: 'Verification',
                        icon: Icons.verified_outlined,
                        subtitle: 'Required for credential review',
                      ),

                      RegistrationTextField(
                        label: 'License Number',
                        hintText: 'Medical license number',
                        controller: _licenseController,
                        keyboardType: TextInputType.text,
                        prefixIcon: Icons.badge_outlined,
                        focusNode: _licenseFocus,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) => FocusScope.of(context)
                            .requestFocus(_clinicAddressFocus),
                      ),
                      SizedBox(height: 16.h),

                      RegistrationTextField(
                        label: 'Clinic Address',
                        hintText: 'Where you practice',
                        controller: _clinicAddressController,
                        keyboardType: TextInputType.streetAddress,
                        prefixIcon: Icons.location_on_outlined,
                        isRequired: false,
                        focusNode: _clinicAddressFocus,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) => FocusScope.of(context)
                            .requestFocus(_hospitalFocus),
                      ),
                      SizedBox(height: 16.h),

                      RegistrationTextField(
                        label: 'Hospital / Clinic Name',
                        hintText: 'Where are you affiliated?',
                        controller: _hospitalController,
                        keyboardType: TextInputType.text,
                        prefixIcon: Icons.apartment_outlined,
                        isRequired: false,
                        focusNode: _hospitalFocus,
                        textInputAction: TextInputAction.done,
                      ),
                      SizedBox(height: 32.h),

                      // --- Submit Button ---
                      _SubmitButton(
                        isLoading: _isSubmitting,
                        label: 'Submit Application',
                        onPressed: _isSubmitting ? null : _submitForm,
                      ),
                      SizedBox(height: 24.h),

                      // --- Login link ---
                      Center(
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 20.h),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Already have an account? ',
                                style: AppStyles.styleRegular14.copyWith(
                                  color: const Color(0xFF949D9E),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => context.go(AppRouter.kLoginView),
                                child: Text(
                                  'Login',
                                  style: AppStyles.styleMedium14.copyWith(
                                    color: const Color(0xFF1A73E8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ====================================================================
// Private reusable widgets for this screen
// ====================================================================

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40.w,
        height: 40.h,
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 16.sp,
          color: const Color(0xff1E252D),
        ),
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({
    required this.isLoading,
    required this.label,
    this.onPressed,
  });
  final bool isLoading;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xff236DEC),
          disabledBackgroundColor: const Color(0xff236DEC).withValues(alpha: 0.6),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? SizedBox(
                width: 22.w,
                height: 22.h,
                child: const CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.send_rounded, size: 18.sp),
                  SizedBox(width: 8.w),
                  Text(label, style: AppStyles.styleSemiBold16),
                ],
              ),
      ),
    );
  }
}

/// A highlighted info banner telling doctors their account requires review.
class _ApprovalNotice extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: const Color(0xFFFDBA74).withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32.w,
            height: 32.h,
            decoration: BoxDecoration(
              color: const Color(0xFFF97316).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              Icons.info_outline_rounded,
              color: const Color(0xFFF97316),
              size: 18.sp,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Verification Required',
                  style: AppStyles.styleMedium14.copyWith(
                    color: const Color(0xFF9A3412),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Your account will be reviewed by our admin team before activation. This usually takes 1-2 business days.',
                  style: AppStyles.styleRegular12.copyWith(
                    color: const Color(0xFFEA580C),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
