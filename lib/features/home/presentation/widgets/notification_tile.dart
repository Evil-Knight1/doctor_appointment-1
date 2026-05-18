import 'package:doctor_appointment/core/theme/app_theme_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:doctor_appointment/core/utils/app_dimensions.dart';
import 'package:doctor_appointment/features/home/domain/entities/notification_entity.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:doctor_appointment/core/services/service_locator.dart';
import 'package:doctor_appointment/features/doctors/data/datasources/doctors_remote_data_source.dart';
import 'package:doctor_appointment/core/utils/go_router.dart';
import 'package:go_router/go_router.dart';

class NotificationTile extends StatefulWidget {
  const NotificationTile({super.key, required this.notification, this.onTap});
  final NotificationEntity notification;
  final VoidCallback? onTap;

  @override
  State<NotificationTile> createState() => _NotificationTileState();
}

class _NotificationTileState extends State<NotificationTile> {
  String? _fetchedDoctorName;
  String? _fetchedDoctorPic;

  @override
  void initState() {
    super.initState();
    _loadDoctorIfNeeded();
  }

  void _loadDoctorIfNeeded() async {
    final isChat = widget.notification.type == 5 ||
        (widget.notification.relatedEntityId != null &&
            (widget.notification.title.toLowerCase().contains('message') ||
                widget.notification.title.toLowerCase().contains('chat')));

    if (isChat && widget.notification.relatedEntityId != null) {
      final docId = int.tryParse(widget.notification.relatedEntityId!);
      if (docId != null) {
        try {
          final doctorDataSource = getIt<DoctorsRemoteDataSource>();
          final doctor = await doctorDataSource.getDoctorById(docId);
          if (mounted) {
            setState(() {
              _fetchedDoctorName = doctor.fullName;
              _fetchedDoctorPic = doctor.profilePictureUrl;
            });
          }
        } catch (_) {}
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = _getThemeForType(context, widget.notification.type);
    final timeAgo = _formatTimestamp(widget.notification.createdAt);

    final isChat = widget.notification.type == 5 ||
        (widget.notification.relatedEntityId != null &&
            (widget.notification.title.toLowerCase().contains('message') ||
                widget.notification.title.toLowerCase().contains('chat')));

    final String displayTitle;
    final String displayMessage;

    if (isChat) {
      if (_fetchedDoctorName != null) {
        displayTitle = 'New Message from Dr. $_fetchedDoctorName';
      } else {
        displayTitle = widget.notification.title.isNotEmpty
            ? widget.notification.title
            : 'New Message';
      }

      displayMessage = widget.notification.message.isNotEmpty &&
              widget.notification.message != 'You received a new message'
          ? widget.notification.message
          : 'Tap to read the conversation';
    } else {
      displayTitle = widget.notification.title;
      displayMessage = widget.notification.message;
    }

    return GestureDetector(
      onTap: () {
        if (widget.onTap != null) {
          widget.onTap!();
        }

        if (isChat && widget.notification.relatedEntityId != null) {
          context.push(
            '/chat/${widget.notification.relatedEntityId}',
            extra: {
              'otherUserName': _fetchedDoctorName ?? 'Chat',
              'otherUserProfilePicture': _fetchedDoctorPic,
            },
          );
        } else if (widget.notification.type == 1 || widget.notification.type == 235) {
          context.push(AppRouter.kCalendarView);
        }
      },
      child: Container(
        margin: EdgeInsets.only(bottom: AppSpacing.md),
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: widget.notification.isRead
              ? colorScheme.surface
              : colorScheme.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: widget.notification.isRead
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
              child: isChat && _fetchedDoctorPic != null && _fetchedDoctorPic!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      child: CachedNetworkImage(
                        imageUrl: _fetchedDoctorPic!,
                        fit: BoxFit.cover,
                        errorWidget: (_, _, _) => Icon(
                          Icons.chat_rounded,
                          color: colorScheme.primary,
                          size: 22.sp,
                        ),
                      ),
                    )
                  : Icon(
                      isChat ? Icons.chat_rounded : theme.icon,
                      color: isChat ? colorScheme.primary : theme.color,
                      size: 22.sp,
                    ),
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
                          displayTitle,
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
                    displayMessage,
                    style: context.bodySmall
                        .copyWith(color: colorScheme.onSurfaceVariant),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (!widget.notification.isRead) ...[
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
      case 235:
      case 1:
        return _NotificationTheme(
          icon: Icons.check_circle_rounded,
          color: customColors.success!,
          bg: customColors.success!.withValues(alpha: 0.1),
        );
      case 2170:
      case 2:
        return _NotificationTheme(
          icon: Icons.info_rounded,
          color: colorScheme.primary,
          bg: colorScheme.primary.withValues(alpha: 0.1),
        );
      case 3:
        return _NotificationTheme(
          icon: Icons.warning_rounded,
          color: customColors.warning!,
          bg: customColors.warning!.withValues(alpha: 0.1),
        );
      case 4:
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
