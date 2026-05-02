import 'package:doctor_appointment/core/utils/app_styles.dart';
import 'package:doctor_appointment/features/auth/logic/auth_cubit.dart';
import 'package:doctor_appointment/features/auth/logic/auth_state.dart';
import 'package:doctor_appointment/core/utils/app_images.dart';
import 'package:doctor_appointment/features/auth/presentation/widgets/circular_social_button.dart';
import 'package:doctor_appointment/features/auth/presentation/widgets/custom_divider.dart';
import 'package:doctor_appointment/features/auth/presentation/widgets/registration_date_picker.dart';
import 'package:doctor_appointment/features/auth/presentation/widgets/registration_dropdown.dart';
import 'package:doctor_appointment/features/auth/presentation/widgets/registration_phone_field.dart';
import 'package:doctor_appointment/features/auth/presentation/widgets/registration_text_field.dart';
import 'package:doctor_appointment/features/auth/presentation/widgets/patient_signup/patient_signup_footer.dart';
import 'package:doctor_appointment/features/auth/presentation/widgets/step_progress_indicator.dart';
import 'package:doctor_appointment/features/auth/presentation/widgets/location_picker_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:phone_form_field/phone_form_field.dart';
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
    setState(() {
      _currentPage++;
    });
  }

  void _previousPage() {
    if (_currentPage > 0) {
      setState(() {
        _currentPage--;
      });
    } else {
      context.pop();
    }
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
    final theme = Theme.of(context);
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthFailure) {
          setState(() => _fieldErrors = state.fieldErrors);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: theme.colorScheme.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
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
        final theme = Theme.of(context);
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0.05, 0),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      },
                      child: KeyedSubtree(
                        key: ValueKey<int>(_currentPage),
                        child: _currentPage == 0
                            ? _buildAccountInfoStep()
                            : _buildPersonalInfoStep(isLoading),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
                  child: PatientSignUpFooter(
                    isLoading: isLoading,
                    label: _currentPage == 0 ? 'Continue' : 'Create Account',
                    onPressed: isLoading ? null : (_currentPage == 0 ? _nextPage : _submitForm),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _HeaderButton(
                icon: Icons.arrow_back_ios_new_rounded,
                onTap: _previousPage,
              ),
              Column(
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xff236DEC), Color(0xff0D47A1)],
                    ).createShader(bounds),
                    child: Text(
                      'Patient Registration',
                      style: AppStyles.styleBold16.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Step ${_currentPage + 1} of 2',
                    style: AppStyles.styleMedium12.copyWith(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ],
              ),
              _HeaderButton(
                icon: Icons.help_outline_rounded,
                onTap: () {},
              ),
            ],
          ),
          SizedBox(height: 24.h),
          StepProgressIndicator(
            currentStep: _currentPage,
            totalSteps: 2,
          ),
        ],
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
          Text(
            'Account Info', 
            style: AppStyles.styleSemiBold24.copyWith(
              color: Theme.of(context).textTheme.headlineMedium?.color,
            )
          ),
          SizedBox(height: 8.h),
          Text(
            'Set up your login credentials to get started.',
            style: AppStyles.styleRegular14.copyWith(
              color: Theme.of(context).textTheme.bodyMedium?.color,
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
          RegistrationPhoneField(
            label: 'Phone Number',
            controller: _phoneController,
            focusNode: _phoneFocus,
            serverError: _getServerError('phone'),
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
            serverError: _getServerError('confirmPassword'),
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
          Text(
            'Personal Details', 
            style: AppStyles.styleSemiBold24.copyWith(
              color: Theme.of(context).textTheme.headlineMedium?.color,
            )
          ),
          SizedBox(height: 8.h),
          Text(
            'Complete your profile for a better experience.',
            style: AppStyles.styleRegular14.copyWith(
              color: Theme.of(context).textTheme.bodyMedium?.color,
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
            onTap: _showLocationPicker,
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
          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  void _showLocationPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => LocationPickerSheet(
        title: 'Select Your Location',
        onLocationSelected: (address) {
          setState(() => _addressController.text = address);
        },
      ),
    );
  }
}

class _HeaderButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: theme.brightness == Brightness.dark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Padding(
            padding: EdgeInsets.all(8.w),
            child: Icon(icon, size: 20.sp, color: theme.iconTheme.color),
          ),
        ),
      ),
    );
  }
}
