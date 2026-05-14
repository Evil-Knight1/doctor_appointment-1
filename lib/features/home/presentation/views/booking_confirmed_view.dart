import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:doctor_appointment/core/utils/app_dimensions.dart';
import 'package:doctor_appointment/features/doctors/domain/entities/doctor.dart';
import 'package:doctor_appointment/core/utils/routes.dart';
import '../widgets/booking_confirmed_widgets.dart';
import '../widgets/shared_app_bar.dart';

class BookingConfirmedView extends StatelessWidget {
  const BookingConfirmedView({super.key, this.args});
  final Map<String, dynamic>? args;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final Doctor? doctor = args?['doctor'] as Doctor?;
    final String time = args?['time'] as String? ?? '';
    final String paymentLabel = args?['paymentLabel'] as String? ?? 'Cash at Clinic';

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: const SharedAppBar(title: 'Booking Confirmed'),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(AppSpacing.lg),
              children: [
                const ConfirmedBadge(),
                SizedBox(height: AppSpacing.xxl),
                ConfirmedInfoSection(
                  title: 'Booking Information',
                  children: [
                    BookingInfoRow(
                      icon: Icons.calendar_today_outlined,
                      label: 'Date & Time',
                      value: time.isNotEmpty ? time : 'Appointment Booked',
                      trailing: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: colorScheme.primary),
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: Text(
                          'Get Location',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    Divider(height: 20.h, color: colorScheme.outlineVariant),
                    BookingInfoRow(
                      icon: Icons.payment_outlined,
                      label: 'Payment',
                      value: paymentLabel,
                    ),
                  ],
                ),
                if (doctor != null) ...[
                  SizedBox(height: AppSpacing.xl),
                  ConfirmedInfoSection(
                    title: 'Doctor Information',
                    children: [
                      DoctorInfoRow(doctor: doctor),
                    ],
                  ),
                ],
              ],
            ),
          ),
          BookingConfirmedActions(
            onDone: () => context.goNamed(Routes.homeView),
            onReview: doctor != null
                ? () => context.pushNamed(
                      Routes.bookingReviewView,
                      extra: doctor,
                    )
                : () => context.goNamed(Routes.homeView),
          ),
        ],
      ),
    );
  }
}
