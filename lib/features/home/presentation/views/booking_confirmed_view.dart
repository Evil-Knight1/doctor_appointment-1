import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:doctor_appointment/core/utils/app_dimensions.dart';
import 'package:doctor_appointment/features/doctors/domain/entities/doctor.dart';
import 'package:doctor_appointment/core/utils/routes.dart';
import '../widgets/booking_confirmed_widgets.dart';
import '../widgets/shared_app_bar.dart';
import 'package:doctor_appointment/l10n/app_localizations.dart';

class BookingConfirmedView extends StatelessWidget {
  const BookingConfirmedView({super.key, this.args});
  final Map<String, dynamic>? args;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final Doctor? doctor = args?['doctor'] as Doctor?;
    final String time = args?['time'] as String? ?? '';
    final l10n = AppLocalizations.of(context)!;
    final String paymentLabel = args?['paymentLabel'] as String? ?? l10n.cashAtClinicDefault;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: SharedAppBar(title: AppLocalizations.of(context)!.bookingConfirmedTitle),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(AppSpacing.lg),
              children: [
                const ConfirmedBadge(),
                SizedBox(height: AppSpacing.xxl),
                ConfirmedInfoSection(
                  title: AppLocalizations.of(context)!.bookingInformation,
                  children: [
                    BookingInfoRow(
                      icon: Icons.calendar_today_outlined,
                      label: AppLocalizations.of(context)!.dateAndTime,
                      value: time.isNotEmpty ? time : AppLocalizations.of(context)!.appointmentBooked,
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
                          AppLocalizations.of(context)!.getLocation,
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
                      label: AppLocalizations.of(context)!.paymentLabel,
                      value: paymentLabel,
                    ),
                  ],
                ),
                if (doctor != null) ...[
                  SizedBox(height: AppSpacing.xl),
                  ConfirmedInfoSection(
                    title: AppLocalizations.of(context)!.doctorInformation,
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
