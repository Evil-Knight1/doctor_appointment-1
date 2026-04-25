import 'package:doctor_appointment/core/utils/app_colors.dart';
import 'package:doctor_appointment/core/utils/app_styles.dart';
import 'package:doctor_appointment/core/utils/go_router.dart';
import 'package:doctor_appointment/features/appointment/presentation/models/appointment_draft.dart';
import 'package:doctor_appointment/features/appointment/presentation/widgets/patient_form_field.dart';
import 'package:doctor_appointment/features/payments/presentation/views/checkout_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class PatientDetailsView extends StatefulWidget {
  final AppointmentDraft draft;

  const PatientDetailsView({super.key, required this.draft});

  @override
  State<PatientDetailsView> createState() => _PatientDetailsViewState();
}

class _PatientDetailsViewState extends State<PatientDetailsView> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _ageController = TextEditingController();
  final _detailController = TextEditingController();
  String? _selectedGender;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    _detailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: AppColors.bg,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 16.sp,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        title: Text(
          "Patient's details",
          style: AppStyles.styleSemiBold22.copyWith(fontSize: 18.sp),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8.h),
                PatientFormField(
                  label: 'Full Name',
                  hint: 'John',
                  controller: _nameController,
                ),
                PatientFormField(
                  label: 'Email',
                  hint: 'example@email.com',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                PatientFormField(
                  label: 'Phone number',
                  hint: '+1 234 567 8900',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                ),
                _buildGenderField(),
                PatientFormField(
                  label: 'Age',
                  hint: 'Enter your age',
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                ),
                PatientFormField(
                  label: 'Detail',
                  hint: 'Enter your detail here...',
                  controller: _detailController,
                  maxLines: 4,
                ),
                SizedBox(height: 100.h),
              ],
            ),
          ),
          _buildBottomButton(context),
        ],
      ),
    );
  }

  Widget _buildGenderField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gender',
          style: AppStyles.styleMedium14.copyWith(fontSize: 13.sp),
        ),
        SizedBox(height: 6.h),
        Container(
          height: 46.h,
          padding: EdgeInsets.symmetric(horizontal: 14.w),
          decoration: BoxDecoration(
            color: AppColors.bg,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedGender,
              hint: Text(
                'Select your gender',
                style: AppStyles.styleRegular14.copyWith(
                  color: AppColors.textLight,
                  fontSize: 12.sp,
                ),
              ),
              isExpanded: true,
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.textSecondary,
              ),
              onChanged: (v) => setState(() => _selectedGender = v),
              items: ['Male', 'Female', 'Other']
                  .map(
                    (g) => DropdownMenuItem(
                      value: g,
                      child: Text(g, style: AppStyles.styleMedium14),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
        SizedBox(height: 14.h),
      ],
    );
  }

  Widget _buildBottomButton(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 32.h),
        color: Colors.white,
        child: ElevatedButton(
          onPressed: () => _submit(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14.r),
            ),
            minimumSize: Size(double.infinity, 52.h),
            elevation: 0,
          ),
          child: Text(
            'Continue to Payment',
            style: AppStyles.styleSemiBold16,
          ),
        ),
      ),
    );
  }

  void _submit(BuildContext context) {
    final reason = _detailController.text.trim().isEmpty
        ? 'General consultation'
        : _detailController.text.trim();

    final payload = CheckoutPayload(draft: widget.draft, reason: reason);
    context.push(AppRouter.kCheckoutView, extra: payload);
  }
}
