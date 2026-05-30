import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:doctor_appointment/core/theme/app_theme_extension.dart';

import 'package:doctor_appointment/core/services/service_locator.dart';
import 'package:doctor_appointment/features/auth/presentation/widgets/registration_date_picker.dart';
import 'package:doctor_appointment/features/auth/presentation/widgets/registration_dropdown.dart';
import 'package:doctor_appointment/features/auth/presentation/widgets/registration_phone_field.dart';
import 'package:doctor_appointment/features/auth/presentation/widgets/registration_text_field.dart';
import 'package:doctor_appointment/features/profile/domain/entities/patient_profile.dart';
import 'package:doctor_appointment/features/profile/logic/profile_cubit.dart';
import 'package:doctor_appointment/features/profile/logic/profile_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:doctor_appointment/core/utils/image_url_helper.dart';
import 'package:phone_form_field/phone_form_field.dart';
import 'package:doctor_appointment/l10n/app_localizations.dart';

class EditProfileView extends StatefulWidget {
  final PatientProfile profile;

  const EditProfileView({super.key, required this.profile});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final PhoneController _phoneController;
  late final TextEditingController _addressController;
  DateTime? _dateOfBirth;
  String? _selectedGender;
  String? _localImagePath;
  late final ProfileCubit _profileCubit;

  @override
  void initState() {
    super.initState();
    _profileCubit = getIt<ProfileCubit>();
    _nameController = TextEditingController(text: widget.profile.fullName);
    _phoneController = PhoneController(
      initialValue: PhoneNumber.parse(widget.profile.phone),
    );
    _addressController = TextEditingController(
      text: widget.profile.address ?? '',
    );
    _dateOfBirth = widget.profile.dateOfBirth;
    _selectedGender = widget.profile.gender;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (image != null) {
      setState(() => _localImagePath = image.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _profileCubit,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            onPressed: () => context.pop(),
          ),
          title: Text(
            AppLocalizations.of(context)!.editProfileTitle,
            style: context.styleSemiBold18.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        body: BlocConsumer<ProfileCubit, ProfileState>(
          listener: (context, state) {
            if (state is ProfileFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: context.customColors.error,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
            if (state is ProfileSuccess) {
              context.pop(true);
            }
          },
          builder: (context, state) {
            final isLoading = state is ProfileLoading;
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Stack(
                        children: [
                          Container(
                            width: 100.r,
                            height: 100.r,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(
                                context,
                              ).colorScheme.primaryContainer,
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: _localImagePath != null
                                  ? Image.file(
                                      File(_localImagePath!),
                                      fit: BoxFit.cover,
                                    )
                                  : (widget.profile.profilePicture != null
                                        ? CachedNetworkImage(
                                            imageUrl: ImageUrlHelper.getFullUrl(
                                              widget.profile.profilePicture,
                                            ),
                                            httpHeaders:
                                                ImageUrlHelper.getImageHeaders(),
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) =>
                                                Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        color: Theme.of(
                                                          context,
                                                        ).colorScheme.primary,
                                                      ),
                                                ),
                                            errorWidget:
                                                (context, url, error) => Icon(
                                                  Icons.person_rounded,
                                                  size: 50.sp,
                                                  color: Theme.of(
                                                    context,
                                                  ).colorScheme.primary,
                                                ),
                                          )
                                        : Icon(
                                            Icons.person_rounded,
                                            size: 50.sp,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                          )),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _pickImage,
                              child: Container(
                                padding: EdgeInsets.all(8.w),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.surface,
                                    width: 2,
                                  ),
                                ),
                                child: Icon(
                                  Icons.camera_alt_rounded,
                                  color: Colors.white,
                                  size: 16.sp,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 32.h),
                    RegistrationTextField(
                      controller: _nameController,
                      label: AppLocalizations.of(context)!.fullName,
                      hintText: AppLocalizations.of(context)!.enterFullName,
                      prefixIcon: Icons.person_outline_rounded,
                      validator: (value) => value == null || value.isEmpty
                          ? AppLocalizations.of(context)!.nameRequired
                          : null,
                    ),
                    SizedBox(height: 20.h),
                    RegistrationPhoneField(
                      controller: _phoneController,
                      label: AppLocalizations.of(context)!.phoneNumberLabel,
                    ),
                    SizedBox(height: 20.h),
                    RegistrationDropdown<String>(
                      label: AppLocalizations.of(context)!.genderLabel,
                      value: _selectedGender,
                      onChanged: (val) => setState(() => _selectedGender = val),
                      prefixIcon: Icons.person_search_outlined,
                      hintText: AppLocalizations.of(context)!.selectGender,
                      items: [
                        DropdownMenuItem(value: 'Male', child: Text(AppLocalizations.of(context)!.maleLabel)),
                        DropdownMenuItem(
                          value: 'Female',
                          child: Text(AppLocalizations.of(context)!.femaleLabel),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h),
                    RegistrationDatePicker(
                      label: AppLocalizations.of(context)!.dateOfBirthLabel,
                      selectedDate: _dateOfBirth,
                      onDateSelected: (date) =>
                          setState(() => _dateOfBirth = date),
                      prefixIcon: Icons.calendar_today_outlined,
                      hintText: '',
                    ),
                    SizedBox(height: 20.h),
                    RegistrationTextField(
                      controller: _addressController,
                      label: AppLocalizations.of(context)!.addressLabel,
                      hintText: AppLocalizations.of(context)!.enterAddress,
                      prefixIcon: Icons.location_on_outlined,
                    ),
                    SizedBox(height: 40.h),
                    SizedBox(
                      width: double.infinity,
                      height: 52.h,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                          elevation: 0,
                        ),
                        child: isLoading
                            ? SizedBox(
                                width: 24.w,
                                height: 24.h,
                                child: const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                AppLocalizations.of(context)!.saveChanges,
                                style: context.styleSemiBold16.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                ),
                              ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) {
      return;
    }
    _profileCubit.updateProfile(
      fullName: _nameController.text.trim(),
      phone: _phoneController.value!.international,
      gender: _selectedGender,
      address: _addressController.text.trim().isEmpty
          ? null
          : _addressController.text.trim(),
      dateOfBirth: _dateOfBirth,
      profilePicturePath: _localImagePath,
    );
  }
}
