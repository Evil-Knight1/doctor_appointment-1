import 'package:doctor_appointment/core/theme/app_theme_extension.dart';
import 'package:doctor_appointment/core/utils/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:doctor_appointment/core/utils/app_dimensions.dart';
import 'package:doctor_appointment/features/home/domain/entities/notification_entity.dart';
import 'package:intl/intl.dart';

class NotificationTile extends StatelessWidget {
  const NotificationTile({super.key, required this.notification, this.onTap});
  final NotificationEntity notification;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = _getThemeForType(context, notification.type);
    final timeAgo = _formatTimestamp(notification.createdAt);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: AppSpacing.md),
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: notification.isRead
              ? colorScheme.surface
              : colorScheme.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: notification.isRead
              ? null
              : Border.all(
                  color: colorScheme.primary.withValues(alpha: 0.15),
                  width: 1.w,
                ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.07),
              blurRadius: 10.r,
              offset: Offset(0, 3.h),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44.w,
              height: 44.h,
              decoration: BoxDecoration(
                color: theme.bg,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(theme.icon, color: theme.color, size: 22.sp),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: context.headingSmall
                              .copyWith(color: colorScheme.onSurface),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        timeAgo,
                        style: context.bodySmall
                            .copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    notification.message,
                    style: context.bodySmall
                        .copyWith(color: colorScheme.onSurfaceVariant),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (!notification.isRead) ...[
              SizedBox(width: 8.w),
              Container(
                width: 8.w,
                height: 8.h,
                margin: EdgeInsets.only(top: 4.h),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else {
      return DateFormat('MMM d').format(dateTime);
    }
  }

  _NotificationTheme _getThemeForType(BuildContext context, int type) {
    final customColors = context.customColors;
    final colorScheme = Theme.of(context).colorScheme;

    switch (type) {
      case 235: // Success / Appointment
      case 1:
        return _NotificationTheme(
          icon: Icons.check_circle_rounded,
          color: customColors.success!,
          bg: customColors.success!.withValues(alpha: 0.1),
        );
      case 2170: // Info / Update
      case 2:
        return _NotificationTheme(
          icon: Icons.info_rounded,
          color: colorScheme.primary,
          bg: colorScheme.primary.withValues(alpha: 0.1),
        );
      case 3: // Warning / Reminder
        return _NotificationTheme(
          icon: Icons.warning_rounded,
          color: customColors.warning!,
          bg: customColors.warning!.withValues(alpha: 0.1),
        );
      case 4: // Error / Alert
        return _NotificationTheme(
          icon: Icons.error_rounded,
          color: customColors.error!,
          bg: customColors.error!.withValues(alpha: 0.1),
        );
      default:
        return _NotificationTheme(
          icon: Icons.notifications_rounded,
          color: colorScheme.primary,
          bg: colorScheme.primary.withValues(alpha: 0.1),
        );
    }
  }
}

class _NotificationTheme {
  final IconData icon;
  final Color color;
  final Color bg;

  const _NotificationTheme({
    required this.icon,
    required this.color,
    required this.bg,
  });
}
