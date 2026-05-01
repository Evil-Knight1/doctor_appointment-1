import 'package:doctor_appointment/core/utils/app_colors.dart';
import 'package:doctor_appointment/core/utils/app_styles.dart';
import 'package:doctor_appointment/core/utils/go_router.dart';
import 'package:doctor_appointment/features/auth/logic/auth_cubit.dart';
import 'package:doctor_appointment/features/auth/logic/auth_state.dart';
import 'package:doctor_appointment/core/utils/app_images.dart';
import 'package:doctor_appointment/features/auth/presentation/widgets/circular_social_button.dart';
import 'package:doctor_appointment/features/auth/presentation/widgets/custom_divider.dart';
import 'package:doctor_appointment/features/auth/presentation/widgets/form_section_header.dart';
import 'package:doctor_appointment/features/auth/presentation/widgets/registration_date_picker.dart';
import 'package:doctor_appointment/features/auth/presentation/widgets/registration_dropdown.dart';
import 'package:doctor_appointment/features/auth/presentation/widgets/registration_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:phone_form_field/phone_form_field.dart';
import 'package:doctor_appointment/features/auth/presentation/widgets/patient_signup/location_picker_dialog.dart';
import 'package:doctor_appointment/core/widgets/image_picker_widget.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final _formKey = GlobalKey<FormState>();

  // --- Controllers ---
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = PhoneController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _addressController = TextEditingController();

  // --- Focus Nodes ---
  final _emailFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();
  final _addressFocus = FocusNode();

  // --- Optional fields ---
  DateTime? _dateOfBirth;
  String? _selectedGender;
  String? _profilePicturePath;

  /// Per-field server validation errors keyed by field name
  Map<String, String> _fieldErrors = {};

  String? _getServerError(String key) => _fieldErrors[key.toLowerCase()];

  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _addressController.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    _addressFocus.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage == 0) {
      if (_formKey.currentState?.validate() != true) return;
      if (_passwordController.text.trim() !=
          _confirmPasswordController.text.trim()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Passwords do not match'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _submitForm() {
    setState(() => _fieldErrors = {});
    if (_formKey.currentState?.validate() != true) return;

    context.read<AuthCubit>().registerPatient(
      fullName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.value.international,
      password: _passwordController.text.trim(),
      dateOfBirth: _dateOfBirth,
      gender: _selectedGender,
      address: _addressController.text.trim().isNotEmpty
          ? _addressController.text.trim()
          : null,
      profilePicturePath: _profilePicturePath,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthFailure) {
          setState(() => _fieldErrors = state.fieldErrors);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: const Color(0xFFEF4444),
            ),
          );
        }
        if (state is AuthSuccess) {
          context.go(state.targetRoute);
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.black,
              ),
              onPressed: () {
                if (_currentPage > 0) {
                  _previousPage();
                } else {
                  context.pop();
                }
              },
            ),
            title: Row(
              children: [
                _buildStepIndicator(0),
                SizedBox(width: 8.w),
                _buildStepIndicator(1),
              ],
            ),
          ),
          body: Form(
            key: _formKey,
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (int page) {
                setState(() => _currentPage = page);
              },
              children: [
                _buildAccountInfoStep(),
                _buildPersonalInfoStep(isLoading),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStepIndicator(int step) {
    bool isActive = _currentPage >= step;
    return Expanded(
      child: Container(
        height: 4.h,
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : const Color(0xFFE2E8F0),
          borderRadius: BorderRadius.circular(2.r),
        ),
      ),
    );
  }

  Widget _buildAccountInfoStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 12.h),
          Text('Account Info', style: AppStyles.styleSemiBold24),
          SizedBox(height: 8.h),
          Text(
            'Set up your login credentials to get started.',
            style: AppStyles.styleRegular14.copyWith(
              color: const Color(0xFF949D9E),
            ),
          ),
          SizedBox(height: 32.h),
          RegistrationTextField(
            label: 'Email',
            hintText: 'example@email.com',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.email_outlined,
            focusNode: _emailFocus,
            textInputAction: TextInputAction.next,
            serverError: _getServerError('email'),
            validator: (value) {
              if (value == null || value.trim().isEmpty)
                return 'Email is required';
              if (!RegExp(
                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
              ).hasMatch(value.trim())) {
                return 'Enter a valid email address';
              }
              return null;
            },
          ),
          SizedBox(height: 16.h),
          PhoneFormField(
            controller: _phoneController,
            decoration: _inputDecoration(
              'Phone Number',
              Icons.phone_outlined,
              'phone',
            ),
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
            serverError: _getServerError('password'),
            validator: (value) {
              if (value == null || value.trim().isEmpty)
                return 'Password is required';
              if (value.trim().length < 6)
                return 'Password must be at least 6 characters';
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
            serverError: _getServerError('confirmPassword'),
          ),
          SizedBox(height: 40.h),
          _SubmitButton(
            isLoading: false,
            label: 'Continue',
            onPressed: _nextPage,
          ),
          SizedBox(height: 24.h),
          const CustomDivider(),
          SizedBox(height: 24.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularSocialButton(icon: Assets.imagesGoogle, onTap: () {}),
              SizedBox(width: 32.w),
              CircularSocialButton(icon: Assets.imagesFacebook, onTap: () {}),
            ],
          ),
          SizedBox(height: 24.h),
          Center(
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
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoStep(bool isLoading) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 12.h),
          Text('Personal Details', style: AppStyles.styleSemiBold24),
          SizedBox(height: 8.h),
          Text(
            'Complete your profile for a better experience.',
            style: AppStyles.styleRegular14.copyWith(
              color: const Color(0xFF949D9E),
            ),
          ),
          SizedBox(height: 32.h),
          Center(
            child: ProfileImagePicker(
              imagePath: _profilePicturePath,
              onImageSelected: (path) =>
                  setState(() => _profilePicturePath = path),
            ),
          ),
          SizedBox(height: 32.h),
          RegistrationTextField(
            label: 'Full Name',
            hintText: 'e.g. John Doe',
            controller: _nameController,
            keyboardType: TextInputType.name,
            prefixIcon: Icons.person_outline_rounded,
            textInputAction: TextInputAction.next,
            serverError: _getServerError('fullName'),
          ),
          SizedBox(height: 16.h),
          RegistrationDatePicker(
            label: 'Date of Birth',
            hintText: 'Select your date of birth',
            selectedDate: _dateOfBirth,
            isRequired: false,
            prefixIcon: Icons.cake_outlined,
            onDateSelected: (date) => setState(() => _dateOfBirth = date),
          ),
          SizedBox(height: 16.h),
          RegistrationDropdown<String>(
            label: 'Gender',
            hintText: 'Select gender',
            value: _selectedGender,
            isRequired: false,
            prefixIcon: Icons.wc_outlined,
            items: const [
              DropdownMenuItem(value: 'male', child: Text('Male')),
              DropdownMenuItem(value: 'female', child: Text('Female')),
            ],
            onChanged: (value) => setState(() => _selectedGender = value),
            validator: (_) => null,
          ),
          SizedBox(height: 16.h),
          GestureDetector(
            onTap: () async {
              final address = await showDialog<String>(
                context: context,
                builder: (context) => const LocationPickerDialog(),
              );
              if (address != null && address.isNotEmpty) {
                setState(() => _addressController.text = address);
              }
            },
            child: AbsorbPointer(
              child: RegistrationTextField(
                label: 'Address',
                hintText: 'Tap to select location on map',
                controller: _addressController,
                prefixIcon: Icons.location_on_outlined,
                isRequired: false,
                focusNode: _addressFocus,
              ),
            ),
          ),
          SizedBox(height: 40.h),
          _SubmitButton(
            isLoading: isLoading,
            label: 'Create Account',
            onPressed: isLoading ? null : _submitForm,
          ),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(
    String label,
    IconData icon,
    String errorKey,
  ) {
    return InputDecoration(
      labelText: label,
      hintText: 'e.g. +216 XX XXX XXX',
      prefixIcon: Icon(icon),
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: const BorderSide(color: Color(0xFFEF4444)),
      ),
      errorText: _getServerError(errorKey),
    );
  }
}

// ====================================================================
// Private reusable widgets for this screen
// ====================================================================

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
          disabledBackgroundColor: const Color(
            0xff236DEC,
          ).withValues(alpha: 0.6),
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
            : Text(label, style: AppStyles.styleSemiBold16),
      ),
    );
  }
}

/// An eye-catching banner card that invites users to register as a doctor.
class _DoctorRegistrationBanner extends StatelessWidget {
  const _DoctorRegistrationBanner({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xff236DEC).withValues(alpha: 0.06),
              const Color(0xff236DEC).withValues(alpha: 0.02),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: const Color(0xff236DEC).withValues(alpha: 0.15),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44.w,
              height: 44.h,
              decoration: BoxDecoration(
                color: const Color(0xff236DEC).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                Icons.medical_services_outlined,
                color: const Color(0xff236DEC),
                size: 22.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Are you a Doctor?',
                    style: AppStyles.styleMedium14.copyWith(
                      color: const Color(0xff236DEC),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Register as a healthcare provider',
                    style: AppStyles.styleRegular12.copyWith(
                      color: const Color(0xFF949D9E),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16.sp,
              color: const Color(0xff236DEC),
            ),
          ],
        ),
      ),
    );
  }
}
