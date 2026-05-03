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

class BookingDateView extends StatefulWidget {
  const BookingDateView({super.key, required this.doctor});
  final DoctorModel doctor;

  @override
  State<BookingDateView> createState() => _BookingDateViewState();
}

class _BookingDateViewState extends State<BookingDateView> {
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String? _selectedTime;

  final List<String> _timeSlots = [
    '08:00 AM', '09:00 AM', '10:00 AM', '11:00 AM',
    '01:00 PM', '02:00 PM', '03:00 PM', '04:00 PM'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: const SharedAppBar(title: 'Book Appointment'),
      body: Column(
        children: [
          const BookingStepper(currentStep: 0),
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(AppSpacing.lg),
              children: [
                Text('Select Date', style: AppTextStyles.headingMedium),
                SizedBox(height: AppSpacing.md),
                _CalendarPlaceholder(
                  selectedDate: _selectedDate,
                  onDateSelected: (d) => setState(() => _selectedDate = d),
                ),
                SizedBox(height: AppSpacing.xl),
                Text('Select Time', style: AppTextStyles.headingMedium),
                SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.md,
                  children: _timeSlots.map((time) {
                    final isSelected = _selectedTime == time;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedTime = time),
                      child: Container(
                        width: (1.sw - AppSpacing.lg * 2 - AppSpacing.md * 2) / 3,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : AppColors.surface,
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : AppColors.divider,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            time,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: isSelected ? Colors.white : AppColors.textPrimary,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          _BottomAction(
            onNext: _selectedTime == null
                ? null
                : () => context.pushNamed(
                      Routes.bookingPaymentView,
                      extra: {
                        'doctor': widget.doctor,
                        'date': _selectedDate,
                        'time': _selectedTime,
                      },
                    ),
          ),
        ],
      ),
    );
  }
}

class _CalendarPlaceholder extends StatelessWidget {
  const _CalendarPlaceholder({required this.selectedDate, required this.onDateSelected});
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('May 2023', style: AppTextStyles.headingSmall),
              Row(
                children: [
                  Icon(Icons.chevron_left, color: AppColors.textSecondary),
                  SizedBox(width: 10.w),
                  Icon(Icons.chevron_right, color: AppColors.textSecondary),
                ],
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
              final date = 8 + index;
              final isSelected = date == 8;
              return Column(
                children: [
                  Text(days[index], style: AppTextStyles.bodySmall.copyWith(fontSize: 10.sp)),
                  SizedBox(height: 8.h),
                  Container(
                    width: 32.w,
                    height: 32.h,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$date',
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _BottomAction extends StatelessWidget {
  const _BottomAction({required this.onNext});
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.xl),
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
          onPressed: onNext,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            disabledBackgroundColor: AppColors.divider,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
            elevation: 0,
          ),
          child: Text(
            'Next',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15.sp),
          ),
        ),
      ),
    );
  }
}
