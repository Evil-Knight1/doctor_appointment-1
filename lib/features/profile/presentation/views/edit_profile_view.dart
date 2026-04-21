import 'package:doctor_appointment/core/utils/app_colors.dart';
import 'package:doctor_appointment/core/utils/app_styles.dart';
import 'package:doctor_appointment/core/services/service_locator.dart';
import 'package:doctor_appointment/features/profile/domain/entities/patient_profile.dart';
import 'package:doctor_appointment/features/profile/logic/profile_cubit.dart';
import 'package:doctor_appointment/features/profile/logic/profile_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class EditProfileView extends StatefulWidget {
  final PatientProfile profile;

  const EditProfileView({super.key, required this.profile});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _genderController;
  late final TextEditingController _addressController;
  DateTime? _dateOfBirth;
  late final ProfileCubit _profileCubit;

  @override
  void initState() {
    super.initState();
    _profileCubit = getIt<ProfileCubit>();
    _nameController = TextEditingController(text: widget.profile.fullName);
    _phoneController = TextEditingController(text: widget.profile.phone);
    _genderController = TextEditingController(
      text: widget.profile.gender ?? '',
    );
    _addressController = TextEditingController(
      text: widget.profile.address ?? '',
    );
    _dateOfBirth = widget.profile.dateOfBirth;
  }

  @override
  void dispose() {
    _profileCubit.close();
    _nameController.dispose();
    _phoneController.dispose();
    _genderController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _profileCubit,
      child: Scaffold(
        backgroundColor: AppColors.bg,
        appBar: AppBar(
          backgroundColor: AppColors.bg,
          elevation: 0,
          title: Text(
            'Edit Profile',
            style: AppStyles.styleSemiBold22.copyWith(fontSize: 18.sp),
          ),
        ),
        body: BlocConsumer<ProfileCubit, ProfileState>(
          listener: (context, state) {
            if (state is ProfileFailure) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
            if (state is ProfileSuccess) {
              context.pop(true);
            }
          },
          builder: (context, state) {
            final isLoading = state is ProfileLoading;
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Full Name'),
                    _buildTextField(
                      controller: _nameController,
                      hintText: 'Enter full name',
                    ),
                    SizedBox(height: 16.h),
                    _buildLabel('Phone'),
                    _buildTextField(
                      controller: _phoneController,
                      hintText: 'Enter phone number',
                      keyboardType: TextInputType.phone,
                    ),
                    SizedBox(height: 16.h),
                    _buildLabel('Gender'),
                    _buildTextField(
                      controller: _genderController,
                      hintText: 'Enter gender',
                    ),
                    SizedBox(height: 16.h),
                    _buildLabel('Address'),
                    _buildTextField(
                      controller: _addressController,
                      hintText: 'Enter address',
                    ),
                    SizedBox(height: 16.h),
                    _buildLabel('Date of Birth'),
                    GestureDetector(
                      onTap: () => _pickDate(context),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 14.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text(
                          _dateOfBirth == null
                              ? 'Select date'
                              : _formatDate(_dateOfBirth!),
                          style: AppStyles.styleRegular14.copyWith(
                            color: _dateOfBirth == null
                                ? AppColors.textLight
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                          minimumSize: Size(double.infinity, 52.h),
                          elevation: 0,
                        ),
                        child: Text(
                          isLoading ? 'Saving...' : 'Save Changes',
                          style: AppStyles.styleSemiBold16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: AppStyles.styleSemiBold22.copyWith(fontSize: 14.sp),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'This field is required';
        }
        return null;
      },
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppStyles.styleRegular14.copyWith(
          color: AppColors.textLight,
        ),
        filled: true,
        fillColor: Colors.white,
        border: _buildBorder(),
        enabledBorder: _buildBorder(),
        focusedBorder: _buildBorder(),
      ),
    );
  }

  OutlineInputBorder _buildBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.r),
      borderSide: const BorderSide(color: AppColors.border),
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final initialDate = _dateOfBirth ?? DateTime(now.year - 18);
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null) {
      setState(() => _dateOfBirth = picked);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) {
      return;
    }
    _profileCubit.updateProfile(
      fullName: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      gender: _genderController.text.trim().isEmpty
          ? null
          : _genderController.text.trim(),
      address: _addressController.text.trim().isEmpty
          ? null
          : _addressController.text.trim(),
      dateOfBirth: _dateOfBirth,
    );
  }
}
