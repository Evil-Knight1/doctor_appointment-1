import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:doctor_appointment/core/utils/app_dimensions.dart';
import 'package:doctor_appointment/features/home/data/models/home_model.dart';
import 'package:doctor_appointment/core/utils/routes.dart';
import 'package:doctor_appointment/core/utils/app_colors.dart';
import '../widgets/booking_confirmed_widgets.dart';
import '../widgets/shared_app_bar.dart';

class BookingConfirmedView extends StatelessWidget {
  const BookingConfirmedView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: const SharedAppBar(title: 'Details'),
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
                      value: 'Wednesday, 08 May 2023\n08:30 AM',
                      trailing: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.primary),
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: Text(
                          'Get Location',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    Divider(height: 20.h, color: AppColors.divider),
                    const BookingInfoRow(
                      icon: Icons.calendar_month_outlined,
                      label: 'Appointment Type',
                      value: 'In Person',
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.xl),
                ConfirmedInfoSection(
                  title: 'Doctor Information',
                  children: [
                    DoctorInfoRow(
                      doctor: HomeStaticData.recommendedDoctors.first,
                    ),
                  ],
                ),
              ],
            ),
          ),
          BookingConfirmedActions(
            onDone: () => context.goNamed(Routes.homeView),
            onReview: () => context.pushNamed(
              Routes.bookingReviewView,
              extra: HomeStaticData.recommendedDoctors.first,
            ),
          ),
        ],
      ),
    );
  }
}
