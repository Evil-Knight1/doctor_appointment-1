import 'package:doctor_appointment/core/theme/app_theme_extension.dart';

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
import 'package:doctor_appointment/l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;
    if (_currentPage == 0) {
      if (_formKey.currentState?.validate() != true) return;
      if (_passwordController.text.trim() !=
          _confirmPasswordController.text.trim()) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.passwordsDoNotMatch),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      // Check whether email & phone are already in use before advancing.
      context.read<AuthCubit>().checkAvailability(
        email: _emailController.text.trim(),
        phone: _phoneController.value.international,
      );
      return; // Wait for AvailabilityChecked state in BlocConsumer listener
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
    final l10n = AppLocalizations.of(context)!;
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
        if (state is AvailabilityChecked) {
          final result = state.result;
          final errors = <String, String>{};
          if (!result.isEmailAvailable) {
            errors['email'] = 'This email is already in use';
          }
          if (!result.isPhoneAvailable) {
            errors['phone'] = 'This phone number is already in use';
          }
          if (errors.isNotEmpty) {
            setState(() => _fieldErrors = errors);
            _formKey.currentState?.validate();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(errors.values.first),
                backgroundColor: theme.colorScheme.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            );
          } else {
            setState(() {
              _fieldErrors = {};
              _currentPage++;
            });
          }
        }
        if (state is AvailabilityCheckFailed) {
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
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading || state is AvailabilityChecking;
        final theme = Theme.of(context);
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(l10n),
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
                            ? _buildAccountInfoStep(l10n)
                            : _buildPersonalInfoStep(isLoading, l10n),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 20.h,
                  ),
                  child: PatientSignUpFooter(
                    isLoading: isLoading,
                    label: _currentPage == 0
                        ? l10n.continueButton
                        : l10n.createAccount,
                    onPressed: isLoading
                        ? null
                        : (_currentPage == 0 ? _nextPage : _submitForm),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
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
                      l10n.patientRegistration,
                      style: context.styleBold16.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    '${l10n.step} ${_currentPage + 1} ${l10n.stepOf} 2',
                    style: context.styleMedium12.copyWith(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ],
              ),
              _HeaderButton(icon: Icons.help_outline_rounded, onTap: () {}),
            ],
          ),
          SizedBox(height: 24.h),
          StepProgressIndicator(currentStep: _currentPage, totalSteps: 2),
        ],
      ),
    );
  }

  Widget _buildAccountInfoStep(AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 12.h),
          Text(
            l10n.accountInfo,
            style: context.styleSemiBold24.copyWith(
              color: Theme.of(context).textTheme.headlineMedium?.color,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            l10n.accountInfoSubtitle,
            style: context.styleRegular14.copyWith(
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
          SizedBox(height: 32.h),
          RegistrationTextField(
            label: l10n.email,
            hintText: 'example@email.com',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.email_outlined,
            focusNode: _emailFocus,
            textInputAction: TextInputAction.next,
            serverError: _getServerError('email'),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return l10n.emailRequired;
              }
              if (!RegExp(
                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
              ).hasMatch(value.trim())) {
                return l10n.emailInvalid;
              }
              return null;
            },
          ),
          RegistrationPhoneField(
            label: l10n.phone,
            controller: _phoneController,
            focusNode: _phoneFocus,
            serverError: _getServerError('phone'),
          ),
          SizedBox(height: 16.h),
          RegistrationTextField(
            label: l10n.password,
            hintText: 'Min. 6 characters',
            controller: _passwordController,
            isPassword: true,
            prefixIcon: Icons.lock_outline_rounded,
            focusNode: _passwordFocus,
            textInputAction: TextInputAction.next,
            serverError: _getServerError('password'),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return l10n.passwordRequired;
              }
              if (value.trim().length < 6) {
                return l10n.passwordShort;
              }
              return null;
            },
          ),
          SizedBox(height: 16.h),
          RegistrationTextField(
            label: l10n.confirmPassword,
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

  Widget _buildPersonalInfoStep(bool isLoading, AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 12.h),
          Text(
            l10n.personalDetails,
            style: context.styleSemiBold24.copyWith(
              color: Theme.of(context).textTheme.headlineMedium?.color,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            l10n.personalDetailsSubtitle,
            style: context.styleRegular14.copyWith(
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
            label: l10n.fullName,
            hintText: 'e.g. John Doe',
            controller: _nameController,
            keyboardType: TextInputType.name,
            prefixIcon: Icons.person_outline_rounded,
            textInputAction: TextInputAction.next,
            serverError: _getServerError('fullName'),
          ),
          SizedBox(height: 16.h),
          RegistrationDatePicker(
            label: l10n.dateOfBirth,
            hintText: 'Select your date of birth',
            selectedDate: _dateOfBirth,
            isRequired: false,
            prefixIcon: Icons.cake_outlined,
            onDateSelected: (date) => setState(() => _dateOfBirth = date),
          ),
          SizedBox(height: 16.h),
          RegistrationDropdown<String>(
            label: l10n.gender,
            hintText: 'Select gender',
            value: _selectedGender,
            isRequired: false,
            prefixIcon: Icons.wc_outlined,
            items: [
              DropdownMenuItem(value: 'male', child: Text(l10n.male)),
              DropdownMenuItem(value: 'female', child: Text(l10n.female)),
            ],
            onChanged: (value) => setState(() => _selectedGender = value),
            validator: (_) => null,
          ),
          SizedBox(height: 16.h),
          GestureDetector(
            onTap: _showLocationPicker,
            child: AbsorbPointer(
              child: RegistrationTextField(
                label: l10n.address,
                hintText: l10n.locationOnMap,
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

  const _HeaderButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: theme.brightness == Brightness.dark ? 0.3 : 0.05,
            ),
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
