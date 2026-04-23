import 'package:doctor_appointment/core/utils/app_styles.dart';
import 'package:doctor_appointment/core/utils/go_router.dart';
import 'package:doctor_appointment/features/auth/logic/auth_cubit.dart';
import 'package:doctor_appointment/features/auth/logic/auth_state.dart';
import 'package:doctor_appointment/features/auth/presentation/widgets/form_section_header.dart';
import 'package:doctor_appointment/features/auth/presentation/widgets/registration_date_picker.dart';
import 'package:doctor_appointment/features/auth/presentation/widgets/registration_dropdown.dart';
import 'package:doctor_appointment/features/auth/presentation/widgets/registration_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

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
  final _phoneController = TextEditingController();
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    context.read<AuthCubit>().registerPatient(
      fullName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      password: _passwordController.text.trim(),
      dateOfBirth: _dateOfBirth,
      gender: _selectedGender,
      address: _addressController.text.trim().isNotEmpty
          ? _addressController.text.trim()
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: const Color(0xFFEF4444),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
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

                          // --- Header ---
                          Text(
                            'Create Patient\nAccount',
                            style: AppStyles.styleSemiBold24,
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'Sign up to find and book appointments with top doctors near you.',
                            style: AppStyles.styleRegular14.copyWith(
                              color: const Color(0xFF949D9E),
                              height: 1.4,
                            ),
                          ),
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
                            hintText: 'e.g. John Doe',
                            controller: _nameController,
                            keyboardType: TextInputType.name,
                            prefixIcon: Icons.person_outline_rounded,
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (_) => FocusScope.of(
                              context,
                            ).requestFocus(_emailFocus),
                          ),
                          SizedBox(height: 16.h),

                          RegistrationTextField(
                            label: 'Email',
                            hintText: 'example@email.com',
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: Icons.email_outlined,
                            focusNode: _emailFocus,
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (_) => FocusScope.of(
                              context,
                            ).requestFocus(_phoneFocus),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Email is required';
                              }
                              if (!RegExp(
                                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                              ).hasMatch(value.trim())) {
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
                            onFieldSubmitted: (_) => FocusScope.of(
                              context,
                            ).requestFocus(_passwordFocus),
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
                            onFieldSubmitted: (_) => FocusScope.of(
                              context,
                            ).requestFocus(_confirmPasswordFocus),
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
                          // SECTION 2: Personal Info
                          // ========================
                          const FormSectionHeader(
                            title: 'Personal Details',
                            icon: Icons.badge_outlined,
                            subtitle:
                                'Optional — helps personalize your experience',
                          ),

                          RegistrationDatePicker(
                            label: 'Date of Birth',
                            hintText: 'Select your date of birth',
                            selectedDate: _dateOfBirth,
                            isRequired: false,
                            prefixIcon: Icons.cake_outlined,
                            onDateSelected: (date) {
                              setState(() => _dateOfBirth = date);
                            },
                          ),
                          SizedBox(height: 16.h),

                          RegistrationDropdown<String>(
                            label: 'Gender',
                            hintText: 'Select gender',
                            value: _selectedGender,
                            isRequired: false,
                            prefixIcon: Icons.wc_outlined,
                            items: const [
                              DropdownMenuItem(
                                value: 'male',
                                child: Text('Male'),
                              ),
                              DropdownMenuItem(
                                value: 'female',
                                child: Text('Female'),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() => _selectedGender = value);
                            },
                            validator: (_) => null,
                          ),
                          SizedBox(height: 16.h),

                          RegistrationTextField(
                            label: 'Address',
                            hintText: 'Your home address',
                            controller: _addressController,
                            keyboardType: TextInputType.streetAddress,
                            prefixIcon: Icons.location_on_outlined,
                            isRequired: false,
                            focusNode: _addressFocus,
                            textInputAction: TextInputAction.done,
                          ),
                          SizedBox(height: 32.h),

                          // --- Submit Button ---
                          _SubmitButton(
                            isLoading: isLoading,
                            label: 'Create Account',
                            onPressed: isLoading ? null : _submitForm,
                          ),
                          SizedBox(height: 20.h),

                          // --- Doctor Registration CTA ---
                          _DoctorRegistrationBanner(
                            onTap: () =>
                                context.push(AppRouter.kDoctorSignUpView),
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
                                    onTap: () =>
                                        context.go(AppRouter.kLoginView),
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
      },
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
