import 'package:cached_network_image/cached_network_image.dart';
import 'package:doctor_appointment/core/services/service_locator.dart';
import 'package:doctor_appointment/core/theme/app_theme_extension.dart';
import 'package:doctor_appointment/core/utils/app_dimensions.dart';
import 'package:doctor_appointment/core/utils/go_router.dart';
import 'package:doctor_appointment/core/utils/image_url_helper.dart';
import 'package:doctor_appointment/core/utils/result.dart';
import 'package:doctor_appointment/features/appointment/domain/entities/appointment.dart';
import 'package:doctor_appointment/features/appointment/domain/usecases/get_my_appointments_usecase.dart';
import 'package:doctor_appointment/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:doctor_appointment/features/chat/data/models/conversation_model.dart';
import 'package:doctor_appointment/features/home/domain/entities/app_notification_type.dart';
import 'package:doctor_appointment/features/home/domain/entities/notification_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:intl/intl.dart';

class NotificationTile extends StatefulWidget {
  const NotificationTile({
    super.key,
    required this.notification,
    this.onTap,
    this.onSeen,
  });

  final NotificationEntity notification;
  final VoidCallback? onTap;
  final VoidCallback? onSeen;

  @override
  State<NotificationTile> createState() => _NotificationTileState();
}

class _NotificationTileState extends State<NotificationTile> {
  int? _resolvedChatUserId;
  String? _resolvedChatPreview;
  String? _resolvedChatName;
  String? _resolvedChatAvatar;

  NotificationEntity get notification => widget.notification;

  @override
  void initState() {
    super.initState();
    _warmUpNotificationMetadata();
  }

  Future<void> _warmUpNotificationMetadata() async {
    if (!notification.notificationType.isChat) return;

    if (!_needsChatEnrichment) return;

    await _enrichChatDisplayFromConversation();
    if (!mounted) return;
    setState(() {});
  }

  bool get _needsChatEnrichment =>
      notification.notificationType.isChat &&
      (_isGenericChatText(notification.message) ||
          (notification.senderName?.trim().isEmpty ?? true) ||
          (notification.senderProfilePicture?.trim().isEmpty ?? true));

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = _getThemeForType(context, notification.notificationType);
    final avatarUrl = _displayAvatarUrl;

    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.xl),
      onTap: () => _handleTap(context),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: EdgeInsets.only(bottom: AppSpacing.md),
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: notification.isRead
              ? theme.highlight.withValues(alpha: 0.03)
              : theme.highlight.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(
            color: notification.isRead
                ? theme.highlight.withValues(alpha: 0.15)
                : theme.highlight.withValues(alpha: 0.4),
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.05),
              blurRadius: 14.r,
              offset: Offset(0, 6.h),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLeading(context, theme, avatarUrl),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          _buildTitle(),
                          style: context.headingSmall.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: notification.isRead
                                ? FontWeight.w600
                                : FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        _formatTimestamp(notification.createdAt),
                        style: context.bodySmall.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    _buildMessage(),
                    style: context.bodySmall.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.45,
                    ),
                    maxLines: notification.notificationType.isChat ? 2 : 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 12.h),
                  if (notification.notificationType.isChat) ...[
                    _buildChatActions(context, theme),
                    SizedBox(height: 12.h),
                  ],
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: theme.softBackground,
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(theme.icon, size: 14.sp, color: theme.color),
                            SizedBox(width: 6.w),
                            Text(
                              notification.notificationType.label,
                              style: context.labelSmall.copyWith(
                                color: theme.color,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      if (!notification.isRead)
                        Container(
                          width: 10.w,
                          height: 10.w,
                          decoration: BoxDecoration(
                            color: theme.highlight,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: theme.highlight.withValues(alpha: 0.35),
                                blurRadius: 8.r,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeading(
    BuildContext context,
    _NotificationTheme theme,
    String? avatarUrl,
  ) {
    final hasAvatar =
        notification.notificationType.isChat &&
        avatarUrl != null &&
        avatarUrl.trim().isNotEmpty;

    if (hasAvatar) {
      return Container(
        width: 56.w,
        height: 56.w,
        padding: EdgeInsets.all(2.w),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              theme.highlight.withValues(alpha: 0.85),
              theme.color.withValues(alpha: 0.65),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: ImageUrlHelper.getFullUrl(avatarUrl),
            httpHeaders: ImageUrlHelper.getImageHeaders(),
            fit: BoxFit.cover,
            errorWidget: (_, _, _) => _buildInitialAvatar(context, theme),
          ),
        ),
      );
    }

    if (notification.notificationType.isChat) {
      return _buildInitialAvatar(context, theme);
    }

    return Container(
      width: 56.w,
      height: 56.w,
      decoration: BoxDecoration(
        color: theme.softBackground,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Icon(theme.icon, color: theme.color, size: 24.sp),
    );
  }

  Widget _buildInitialAvatar(BuildContext context, _NotificationTheme theme) {
    final name = _displaySenderName;
    final initials = name.isNotEmpty ? name[0].toUpperCase() : 'C';

    return Container(
      width: 56.w,
      height: 56.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [theme.highlight, theme.color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          initials,
          style: context.headingMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Future<void> _handleTap(BuildContext context) async {
    _markSeen();

    if (notification.notificationType.isChat) {
      await _openChat(context);
    } else if (notification.notificationType.isAppointmentFlow) {
      await _openAppointmentDetails(context);
    }
  }

  Widget _buildChatActions(BuildContext context, _NotificationTheme theme) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: () async {
              _markSeen();
              await _openChat(context);
            },
            style: FilledButton.styleFrom(
              backgroundColor: theme.highlight,
              foregroundColor: colorScheme.onPrimary,
              elevation: 0,
              padding: EdgeInsets.symmetric(vertical: 10.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
            ),
            icon: Icon(Iconsax.message_edit, size: 16.sp),
            label: Text(
              'Reply',
              style: context.labelLarge.copyWith(
                color: colorScheme.onPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: notification.isRead
                ? null
                : () {
                    _markSeen();
                  },
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.color,
              side: BorderSide(color: theme.highlight.withValues(alpha: 0.35)),
              padding: EdgeInsets.symmetric(vertical: 10.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
            ),
            icon: Icon(Iconsax.tick_circle, size: 16.sp),
            label: Text(
              notification.isRead ? 'Seen' : 'Mark seen',
              style: context.labelLarge.copyWith(
                color: theme.color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _openChat(BuildContext context) async {
    final chatUserId = _parseChatUserId(notification.relatedEntityId);

    if (chatUserId == null) {
      _showError(context, 'Could not find this conversation');
      return;
    }

    if (_needsChatEnrichment) {
      try {
        final chatRemoteDataSource = getIt<ChatRemoteDataSource>();
        final conversations = await chatRemoteDataSource.getConversations();
        final matchedConversation = conversations
            .where((conversation) => conversation.otherUserId == chatUserId)
            .cast<ConversationModel?>()
            .firstWhere((_) => true, orElse: () => null);
        _resolvedChatUserId = chatUserId;
        _resolvedChatPreview ??= matchedConversation?.lastMessage;
        _resolvedChatName ??= matchedConversation?.otherUserName;
        _resolvedChatAvatar ??= matchedConversation?.otherUserProfilePicture;
      } catch (_) {}
    }

    if (!context.mounted) return;

    await context.push(
      AppRouter.kChatView.replaceFirst(':userId', '$chatUserId'),
      extra: {
        'otherUserName': _displaySenderName.isNotEmpty
            ? _displaySenderName
            : 'Chat',
        'otherUserProfilePicture': _displayAvatarUrl,
      },
    );
  }

  Future<void> _enrichChatDisplayFromConversation() async {
    final chatUserId = _parseChatUserId(notification.relatedEntityId);
    if (chatUserId == null) return;

    try {
      final chatRemoteDataSource = getIt<ChatRemoteDataSource>();
      final conversations = await chatRemoteDataSource.getConversations();
      final matchedConversation = conversations
          .where((conversation) => conversation.otherUserId == chatUserId)
          .cast<ConversationModel?>()
          .firstWhere((_) => true, orElse: () => null);
      if (matchedConversation == null) return;
      _resolvedChatUserId = chatUserId;
      _resolvedChatPreview ??= matchedConversation.lastMessage;
      _resolvedChatName ??= matchedConversation.otherUserName;
      _resolvedChatAvatar ??= matchedConversation.otherUserProfilePicture;
    } catch (_) {}
  }

  Future<void> _openAppointmentDetails(BuildContext context) async {
    final appointmentId = _parseAppointmentId(notification.relatedEntityId);
    if (appointmentId == null) {
      _showError(context, 'Appointment details are unavailable');
      return;
    }

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Center(
        child: Container(
          padding: EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: const CircularProgressIndicator(),
        ),
      ),
    );

    try {
      final useCase = getIt<GetMyAppointmentsUseCase>();
      final result = await useCase();

      if (!context.mounted) return;
      Navigator.of(context).pop();

      if (result is! Success<List<Appointment>>) {
        _showError(context, 'Failed to load appointment details');
        return;
      }

      Appointment? appointment;
      for (final item in result.data) {
        if (item.id == appointmentId) {
          appointment = item;
          break;
        }
      }

      if (appointment == null) {
        _showError(context, 'Appointment details not found');
        return;
      }

      await context.push(AppRouter.kAppointmentDetailsView, extra: appointment);
    } catch (_) {
      if (!context.mounted) return;
      Navigator.of(context).pop();
      _showError(context, 'Failed to open appointment details');
    }
  }

  int? _parseChatUserId(String? raw) {
    final parsed = int.tryParse(raw ?? '');
    if (parsed == null || parsed <= 0) return null;
    return parsed;
  }

  int? _parseAppointmentId(String? raw) {
    final parsed = int.tryParse(raw ?? '');
    if (parsed == null || parsed <= 0) return null;
    return parsed;
  }

  bool _isGenericChatText(String text) {
    final normalized = text.trim().toLowerCase();
    return normalized.isEmpty ||
        normalized == 'you received a new message' ||
        normalized == 'new message arrived' ||
        normalized == 'new message arrive' ||
        normalized == 'tap to continue the conversation';
  }

  String get _displaySenderName {
    final resolvedName = _resolvedChatName?.trim();
    final senderName = notification.senderName?.trim();
    final baseName = (resolvedName != null && resolvedName.isNotEmpty)
        ? resolvedName
        : (senderName ?? '');

    if (baseName.isEmpty) {
      return 'Chat';
    }

    return baseName;
  }

  String? get _displayAvatarUrl =>
      _resolvedChatAvatar ?? notification.senderProfilePicture;

  String _buildTitle() {
    if (notification.notificationType.isChat) {
      return _displaySenderName;
    }

    return notification.title.isNotEmpty
        ? notification.title
        : notification.notificationType.label;
  }

  void _markSeen() {
    if (!notification.isRead) {
      widget.onTap?.call();
      widget.onSeen?.call();
    }
  }

  String _buildMessage() {
    if (notification.notificationType.isChat) {
      if (!_isGenericChatText(notification.message)) {
        return notification.message.trim();
      }

      final resolvedPreview = _resolvedChatPreview?.trim();
      if (resolvedPreview != null && resolvedPreview.isNotEmpty) {
        return resolvedPreview;
      }

      return 'Tap to continue the conversation';
    }

    if (notification.message.trim().isNotEmpty) {
      return notification.message.trim();
    }

    return 'Tap to view more details';
  }

  void _showError(BuildContext context, String message) {
    final colorScheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _formatTimestamp(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'now';
    }
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    }
    if (difference.inHours < 24) {
      return '${difference.inHours}h';
    }
    if (difference.inDays < 7) {
      return '${difference.inDays}d';
    }
    return DateFormat('MMM d').format(dateTime);
  }

  _NotificationTheme _getThemeForType(
    BuildContext context,
    AppNotificationType type,
  ) {
    final customColors = context.customColors;
    final colorScheme = Theme.of(context).colorScheme;

    switch (type) {
      case AppNotificationType.appointmentBooked:
        return _NotificationTheme(
          icon: Iconsax.calendar_add,
          color: colorScheme.primary,
          highlight: colorScheme.primary,
          softBackground: colorScheme.primary.withValues(alpha: 0.12),
        );
      case AppNotificationType.appointmentApproved:
        return _NotificationTheme(
          icon: Iconsax.calendar_tick,
          color: customColors.success ?? colorScheme.primary,
          highlight: customColors.success ?? colorScheme.primary,
          softBackground: (customColors.success ?? colorScheme.primary)
              .withValues(alpha: 0.12),
        );
      case AppNotificationType.appointmentCancelled:
        return _NotificationTheme(
          icon: Iconsax.calendar_remove,
          color: customColors.error ?? colorScheme.error,
          highlight: customColors.error ?? colorScheme.error,
          softBackground: (customColors.error ?? colorScheme.error).withValues(
            alpha: 0.12,
          ),
        );
      case AppNotificationType.appointmentReminder:
        return _NotificationTheme(
          icon: Iconsax.clock_1,
          color: customColors.warning ?? Colors.orange,
          highlight: customColors.warning ?? Colors.orange,
          softBackground: (customColors.warning ?? Colors.orange).withValues(
            alpha: 0.12,
          ),
        );
      case AppNotificationType.chatMessage:
        return _NotificationTheme(
          icon: Iconsax.message_2,
          color: colorScheme.primary,
          highlight: colorScheme.primary,
          softBackground: colorScheme.primary.withValues(alpha: 0.12),
        );
      case AppNotificationType.reviewReceived:
        return _NotificationTheme(
          icon: Iconsax.star_1,
          color: const Color(0xFFFFB648),
          highlight: const Color(0xFFFFB648),
          softBackground: const Color(0xFFFFB648).withValues(alpha: 0.12),
        );
      case AppNotificationType.doctorApproved:
        return _NotificationTheme(
          icon: Iconsax.user_tick,
          color: customColors.success ?? colorScheme.primary,
          highlight: customColors.success ?? colorScheme.primary,
          softBackground: (customColors.success ?? colorScheme.primary)
              .withValues(alpha: 0.12),
        );
      case AppNotificationType.general:
        return _NotificationTheme(
          icon: Iconsax.notification_bing,
          color: colorScheme.secondary,
          highlight: colorScheme.secondary,
          softBackground: colorScheme.secondary.withValues(alpha: 0.12),
        );
      case AppNotificationType.newDoctorRegistration:
        return _NotificationTheme(
          icon: Iconsax.user_tag,
          color: colorScheme.tertiary,
          highlight: colorScheme.tertiary,
          softBackground: colorScheme.tertiary.withValues(alpha: 0.12),
        );
      case AppNotificationType.paymentFailed:
        return _NotificationTheme(
          icon: Iconsax.empty_wallet_remove,
          color: customColors.error ?? colorScheme.error,
          highlight: customColors.error ?? colorScheme.error,
          softBackground: (customColors.error ?? colorScheme.error).withValues(
            alpha: 0.12,
          ),
        );
      case AppNotificationType.unknown:
        return _NotificationTheme(
          icon: Iconsax.info_circle,
          color: colorScheme.primary,
          highlight: colorScheme.primary,
          softBackground: colorScheme.primary.withValues(alpha: 0.12),
        );
    }
  }
}

class _NotificationTheme {
  const _NotificationTheme({
    required this.icon,
    required this.color,
    required this.highlight,
    required this.softBackground,
  });

  final IconData icon;
  final Color color;
  final Color highlight;
  final Color softBackground;
}
