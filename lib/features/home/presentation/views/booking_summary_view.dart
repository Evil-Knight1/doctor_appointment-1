import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:doctor_appointment/core/utils/app_dimensions.dart';
import 'package:doctor_appointment/features/home/data/models/home_model.dart';
import 'package:doctor_appointment/core/utils/routes.dart';
import 'package:doctor_appointment/core/utils/app_colors.dart';
import 'package:doctor_appointment/core/utils/app_styles.dart';
import '../widgets/booking_stepper.dart';
import '../widgets/shared_app_bar.dart';

class BookingSummaryView extends StatelessWidget {
  const BookingSummaryView({super.key, required this.args});
  final Map<String, dynamic> args;

  @override
  Widget build(BuildContext context) {
    final DoctorModel doctor = args['doctor'];
    final String time = args['time'];
    final String payment = args['payment'];

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: const SharedAppBar(title: 'Review Summary'),
      body: Column(
        children: [
          const BookingStepper(currentStep: 2),
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(AppSpacing.lg),
              children: [
                _SectionCard(
                  title: 'Doctor Information',
                  child: Row(
                    children: [
                      Container(
                        width: 60.w,
                        height: 60.h,
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                        ),
                        child: Icon(
                          Icons.person_rounded,
                          color: AppColors.primary,
                          size: 30.sp,
                        ),
                      ),
                      SizedBox(width: AppSpacing.md),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(doctor.name, style: AppTextStyles.headingSmall),
                          Text(
                            '${doctor.speciality} | ${doctor.hospital}',
                            style: AppTextStyles.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppSpacing.lg),
                _SectionCard(
                  title: 'Appointment Details',
                  child: Column(
                    children: [
                      _DetailRow(
                        icon: Icons.calendar_today,
                        label: 'Date',
                        value: 'Wednesday, 08 May 2023',
                      ),
                      Divider(height: 24.h),
                      _DetailRow(
                        icon: Icons.access_time,
                        label: 'Time',
                        value: time,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppSpacing.lg),
                _SectionCard(
                  title: 'Payment Method',
                  child: _DetailRow(
                    icon: Icons.payment,
                    label: 'Method',
                    value: payment,
                    trailing: Text(
                      'Change',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: AppSpacing.lg),
                _SectionCard(
                  title: 'Cost Summary',
                  child: Column(
                    children: [
                      _CostRow(label: 'Consultation', value: '\$60.00'),
                      SizedBox(height: 12.h),
                      _CostRow(label: 'Admin Fee', value: '\$5.00'),
                      Divider(height: 24.h),
                      _CostRow(label: 'Total', value: '\$65.00', isTotal: true),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _BottomAction(
            onConfirm: () => context.goNamed(Routes.bookingConfirmedView),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10.r,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.headingSmall),
          SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.trailing,
  });
  final IconData icon;
  final String label;
  final String value;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18.sp, color: AppColors.primary),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.bodySmall.copyWith(fontSize: 10.sp)),
              Text(
                value,
                style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        ?trailing,
      ],
    );
  }
}

class _CostRow extends StatelessWidget {
  const _CostRow({required this.label, required this.value, this.isTotal = false});
  final String label;
  final String value;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: isTotal ? AppTextStyles.headingSmall : AppTextStyles.bodyMedium),
        Text(
          value,
          style: isTotal
              ? AppTextStyles.headingSmall.copyWith(color: AppColors.primary)
              : AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _BottomAction extends StatelessWidget {
  const _BottomAction({required this.onConfirm});
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.xl,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10.r,
            offset: Offset(0, -4.h),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 50.h,
        child: ElevatedButton(
          onPressed: onConfirm,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            elevation: 0,
          ),
          child: Text(
            'Confirm Payment',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15.sp),
          ),
        ),
      ),
    );
  }
}
