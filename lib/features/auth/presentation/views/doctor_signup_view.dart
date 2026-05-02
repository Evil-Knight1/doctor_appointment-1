
import 'package:doctor_appointment/core/utils/app_styles.dart';
import 'package:doctor_appointment/core/utils/go_router.dart';
import 'package:doctor_appointment/features/auth/presentation/widgets/doctor_signup/doctor_signup_footer.dart';
import 'package:doctor_appointment/features/auth/presentation/widgets/doctor_signup/doctor_signup_form.dart';
import 'package:doctor_appointment/features/auth/presentation/widgets/location_picker_sheet.dart';
import 'package:doctor_appointment/features/auth/logic/auth_cubit.dart';
import 'package:doctor_appointment/features/auth/logic/auth_state.dart';
import 'package:doctor_appointment/features/auth/presentation/widgets/step_progress_indicator.dart';
import 'package:doctor_appointment/features/doctors/domain/entities/specialization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:phone_form_field/phone_form_field.dart';

class DoctorSignUpView extends StatefulWidget {
  const DoctorSignUpView({super.key});

  @override
  State<DoctorSignUpView> createState() => _DoctorSignUpViewState();
}

class _DoctorSignUpViewState extends State<DoctorSignUpView> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  int _currentStep = 0;
  bool _isSubmitting = false;

  // --- Controllers ---
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = PhoneController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _yearsController = TextEditingController();
  final _licenseController = TextEditingController();
  final _bioController = TextEditingController();
  final _clinicAddressController = TextEditingController();
  final _hospitalController = TextEditingController();
  DateTime? _dateOfBirth;
  String? _selectedGender;

  Specialization? _selectedSpecialization;
  String? _profilePicturePath;
  List<String> _clinicImagesPaths = [];

  /// Per-field server validation errors to show inline.
  Map<String, String> _fieldErrors = {};

  @override
  void dispose() {
    _pageController.dispose();
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
    super.dispose();
  }

  void _nextStep() {
    if (_formKey.currentState?.validate() != true) return;

    if (_currentStep == 0) {
      if (_passwordController.text != _confirmPasswordController.text) {
        _showErrorSnackBar('Passwords do not match');
        return;
      }
    }

    if (_currentStep < 2) {
      setState(() {
        _currentStep++;
      });
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _submitForm();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      context.pop();
    }
  }

  void _showLocationPicker({required bool forClinic}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => LocationPickerSheet(
        title: forClinic
            ? 'Select Clinic Location'
            : 'Select Hospital Location',
        onLocationSelected: (address) {
          setState(() {
            if (forClinic) {
              _clinicAddressController.text = address;
            } else {
              _hospitalController.text = address;
            }
          });
        },
      ),
    );
  }

  void _submitForm() {
    setState(() => _fieldErrors = {});

    if (_selectedSpecialization == null) {
      _showErrorSnackBar('Please select a specialization');
      return;
    }

    context.read<AuthCubit>().registerDoctor(
      fullName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.value.international,
      password: _passwordController.text.trim(),
      specializationId: _selectedSpecialization!.id,
      experienceYears: int.tryParse(_yearsController.text) ?? 0,
      licenseId: _licenseController.text.trim(),
      clinicAddress: _clinicAddressController.text.trim(),
      hospitalName: _hospitalController.text.trim(),
      bio: _bioController.text.trim(),
      profilePicturePath: _profilePicturePath,
      clinicImagesPaths: _clinicImagesPaths,
      gender: _selectedGender,
      dateOfBirth: _dateOfBirth,
    );
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: theme.colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthLoading) {
          setState(() {
            _isSubmitting = true;
            _fieldErrors = {};
          });
        } else if (state is AuthSuccess) {
          setState(() => _isSubmitting = false);
          SchedulerBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              context.push(AppRouter.kDoctorPendingApprovalView);
            }
          });
        } else if (state is AuthFailure) {
          setState(() {
            _isSubmitting = false;
            _fieldErrors = state.fieldErrors;
          });
          if (state.fieldErrors.isEmpty) {
            _showErrorSnackBar(state.message);
          }
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _HeaderButton(
                          icon: Icons.arrow_back_ios_new_rounded,
                          onTap: _previousStep,
                        ),
                        Column(
                          children: [
                            ShaderMask(
                              shaderCallback: (bounds) => LinearGradient(
                                colors: [
                                  Theme.of(context).colorScheme.primary,
                                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                                ],
                              ).createShader(bounds),
                              child: Text(
                                'Doctor Registration',
                                style: AppStyles.styleBold16.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              'Step ${_currentStep + 1} of 3',
                              style: AppStyles.styleMedium12.copyWith(
                                color: Theme.of(context).textTheme.bodyMedium?.color,
                              ),
                            ),
                          ],
                        ),
                        _HeaderButton(
                          icon: Icons.help_outline_rounded,
                          onTap: _showHelpDialog,
                        ),
                      ],
                    ),
                    SizedBox(height: 24.h),
                    StepProgressIndicator(
                      currentStep: _currentStep,
                      totalSteps: 3,
                    ),
                  ],
                ),
              ),
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
                      key: ValueKey<int>(_currentStep),
                      child: _buildCurrentStep(),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                child: DoctorSignUpFooter(
                  isLoading: _isSubmitting,
                  onSubmit: _nextStep,
                  isLastStep: _currentStep == 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildStep1();
      case 1:
        return _buildStep2();
      case 2:
        return _buildStep3();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Account Credentials', style: AppStyles.styleSemiBold20.copyWith(
            color: Theme.of(context).textTheme.headlineMedium?.color,
          )),
          SizedBox(height: 8.h),
          Text(
            'Enter your email, password and phone to get started.',
            style: AppStyles.styleRegular14.copyWith(
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
          SizedBox(height: 24.h),
          DoctorSignUpForm(
            step: 1,
            emailController: _emailController,
            phoneController: _phoneController,
            passwordController: _passwordController,
            confirmPasswordController: _confirmPasswordController,
            fieldErrors: _fieldErrors,
            formKey: _formKey,
            onShowClinicLocationPicker: () => _showLocationPicker(forClinic: true),
            onShowHospitalLocationPicker: () => _showLocationPicker(forClinic: false),
            nameController: _nameController,
            yearsController: _yearsController,
            licenseController: _licenseController,
            bioController: _bioController,
            clinicAddressController: _clinicAddressController,
            hospitalController: _hospitalController,
            selectedSpecialization: _selectedSpecialization,
            onSpecializationChanged: (spec) => setState(() => _selectedSpecialization = spec),
            profilePicturePath: _profilePicturePath,
            onProfilePictureChanged: (path) => setState(() => _profilePicturePath = path),
            clinicImagesPaths: _clinicImagesPaths,
            onClinicImagesChanged: (paths) => setState(() => _clinicImagesPaths = paths),
            selectedDateOfBirth: _dateOfBirth,
            onDateOfBirthChanged: (date) => setState(() => _dateOfBirth = date),
            selectedGender: _selectedGender,
            onGenderChanged: (gender) => setState(() => _selectedGender = gender),
          ),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Personal Information', style: AppStyles.styleSemiBold20.copyWith(
            color: Theme.of(context).textTheme.headlineMedium?.color,
          )),
          SizedBox(height: 8.h),
          Text(
            'Tell us more about your professional background.',
            style: AppStyles.styleRegular14.copyWith(
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
          SizedBox(height: 24.h),
          DoctorSignUpForm(
            step: 2,
            nameController: _nameController,
            yearsController: _yearsController,
            licenseController: _licenseController,
            bioController: _bioController,
            selectedSpecialization: _selectedSpecialization,
            onSpecializationChanged: (spec) =>
                setState(() => _selectedSpecialization = spec),
            profilePicturePath: _profilePicturePath,
            onProfilePictureChanged: (path) =>
                setState(() => _profilePicturePath = path),
            selectedGender: _selectedGender,
            onGenderChanged: (gender) =>
                setState(() => _selectedGender = gender),
            selectedDateOfBirth: _dateOfBirth,
            onDateOfBirthChanged: (date) => setState(() => _dateOfBirth = date),
            fieldErrors: _fieldErrors,
            formKey: _formKey,
            onShowClinicLocationPicker: () => _showLocationPicker(forClinic: true),
            onShowHospitalLocationPicker: () => _showLocationPicker(forClinic: false),
            emailController: _emailController,
            phoneController: _phoneController,
            passwordController: _passwordController,
            confirmPasswordController: _confirmPasswordController,
            clinicAddressController: _clinicAddressController,
            hospitalController: _hospitalController,
            clinicImagesPaths: _clinicImagesPaths,
            onClinicImagesChanged: (paths) => setState(() => _clinicImagesPaths = paths),
          ),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Clinic Information', style: AppStyles.styleSemiBold20.copyWith(
            color: Theme.of(context).textTheme.headlineMedium?.color,
          )),
          SizedBox(height: 8.h),
          Text(
            'Provide details about your practice location.',
            style: AppStyles.styleRegular14.copyWith(
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
          SizedBox(height: 24.h),
          DoctorSignUpForm(
            step: 3,
            onShowClinicLocationPicker: () =>
                _showLocationPicker(forClinic: true),
            onShowHospitalLocationPicker: () =>
                _showLocationPicker(forClinic: false),
            clinicAddressController: _clinicAddressController,
            hospitalController: _hospitalController,
            clinicImagesPaths: _clinicImagesPaths,
            onClinicImagesChanged: (paths) =>
                setState(() => _clinicImagesPaths = paths),
            fieldErrors: _fieldErrors,
            formKey: _formKey,
            nameController: _nameController,
            emailController: _emailController,
            phoneController: _phoneController,
            passwordController: _passwordController,
            confirmPasswordController: _confirmPasswordController,
            yearsController: _yearsController,
            licenseController: _licenseController,
            bioController: _bioController,
            selectedSpecialization: _selectedSpecialization,
            onSpecializationChanged: (spec) => setState(() => _selectedSpecialization = spec),
            profilePicturePath: _profilePicturePath,
            onProfilePictureChanged: (path) => setState(() => _profilePicturePath = path),
            selectedDateOfBirth: _dateOfBirth,
            onDateOfBirthChanged: (date) => setState(() => _dateOfBirth = date),
            selectedGender: _selectedGender,
            onGenderChanged: (gender) => setState(() => _selectedGender = gender),
          ),
          SizedBox(height: 24.h),
        ],
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
