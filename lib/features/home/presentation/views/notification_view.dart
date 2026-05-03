import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:doctor_appointment/core/utils/app_dimensions.dart';
import 'package:doctor_appointment/features/home/data/models/home_model.dart';
import 'package:doctor_appointment/core/utils/app_colors.dart';
import 'package:doctor_appointment/core/utils/app_styles.dart';
import '../widgets/notification_tile.dart';
import '../widgets/shared_app_bar.dart';

const _todayNotifs = [
  NotificationItemModel(
    title: 'Appointment Success',
    message:
        "Congratulations – your appointment is confirmed! We're looking forward to meeting with you.",
    timeAgo: '1h',
    icon: Icons.check_circle_outline_rounded,
    iconColor: Color(0xFF059669),
    iconBg: Color(0xFFECFDF5),
  ),
  NotificationItemModel(
    title: 'Schedule Changed',
    message:
        'You have successfully changed your appointment with Dr. Randy Wigham.',
    timeAgo: '3h',
    icon: Icons.calendar_today_outlined,
    iconColor: Color(0xFF2563EB),
    iconBg: Color(0xFFEFF6FF),
  ),
  NotificationItemModel(
    title: 'Video Call Appointment',
    message: "We'll send you a link to join the call at the booking details.",
    timeAgo: '7h',
    icon: Icons.videocam_outlined,
    iconColor: Color(0xFF7C3AED),
    iconBg: Color(0xFFF5F3FF),
  ),
];

const _yesterdayNotifs = [
  NotificationItemModel(
    title: 'Appointment Cancelled',
    message:
        'You have successfully canceled your appointment with Dr. Randy Wigham. 50% of the funds will be returned.',
    timeAgo: '1d',
    icon: Icons.cancel_outlined,
    iconColor: Color(0xFFDC2626),
    iconBg: Color(0xFFFEF2F2),
    isRead: true,
    isToday: false,
  ),
  NotificationItemModel(
    title: 'New Payment Added!',
    message: 'Your payment has been successfully linked with Docdoc.',
    timeAgo: '1d',
    icon: Icons.payment_outlined,
    iconColor: Color(0xFFD97706),
    iconBg: Color(0xFFFFFBEB),
    isRead: true,
    isToday: false,
  ),
];

class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: SharedAppBar(
        title: 'Notification',
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 10.w,
                  vertical: 4.h,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  '3 NEW',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(AppSpacing.lg),
        children: [
          _SectionLabel(label: 'Today', onMarkAll: () {}),
          SizedBox(height: AppSpacing.md),
          ..._todayNotifs.map((n) => NotificationTile(item: n)),
          SizedBox(height: AppSpacing.xl),
          const _SectionLabel(label: 'Yesterday'),
          SizedBox(height: AppSpacing.md),
          ..._yesterdayNotifs.map((n) => NotificationTile(item: n)),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, this.onMarkAll});
  final String label;
  final VoidCallback? onMarkAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.headingSmall),
        if (onMarkAll != null)
          GestureDetector(
            onTap: onMarkAll,
            child: Text(
              'Mark all as read',
              style: AppTextStyles.labelLarge,
            ),
          ),
      ],
    );
  }
}
