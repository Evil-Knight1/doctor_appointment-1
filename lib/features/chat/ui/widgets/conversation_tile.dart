import 'package:doctor_appointment/core/theme/app_theme_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:doctor_appointment/core/utils/app_styles.dart';
import 'package:doctor_appointment/features/chat/data/models/conversation_model.dart';
import 'package:doctor_appointment/core/utils/image_url_helper.dart';
import 'package:intl/intl.dart';

class ConversationTile extends StatelessWidget {
  final ConversationModel conversation;
  final VoidCallback onTap;
  final bool isAi;

  const ConversationTile({
    super.key,
    required this.conversation,
    required this.onTap,
    this.isAi = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasUnread = conversation.unreadCount > 0;

    return InkWell(
      onTap: onTap,
      splashColor: colorScheme.primaryContainer.withValues(alpha: 0.3),
      highlightColor: colorScheme.primaryContainer.withValues(alpha: 0.2),
      child: Container(
        color: hasUnread
            ? colorScheme.primaryContainer.withValues(alpha: 0.2)
            : Colors.transparent,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Row(
          children: [
            _buildAvatar(context),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conversation.otherUserName,
                          style: context.headingMedium.copyWith(
                            fontSize: 15.sp,
                            fontWeight: hasUnread
                                ? FontWeight.w700
                                : FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        _formatDate(conversation.lastMessageTime),
                        style: context.bodySmall.copyWith(
                          fontSize: 11.sp,
                          color: hasUnread
                              ? colorScheme.primary
                              : colorScheme.onSurfaceVariant,
                          fontWeight: hasUnread
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conversation.lastMessage,
                          style: context.bodySmall.copyWith(
                            color: hasUnread
                                ? colorScheme.onSurface
                                : colorScheme.onSurfaceVariant,
                            fontWeight: hasUnread
                                ? FontWeight.w500
                                : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (hasUnread) ...[
                        SizedBox(width: 8.w),
                        _buildBadge(context, conversation.unreadCount),
                      ],
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

  Widget _buildAvatar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final customColors = context.customColors;
    if (isAi) {
      return Stack(
        children: [
          Container(
            width: 52.r,
            height: 52.r,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFF7C3AED), Color(0xFF2563EB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Icon(Icons.smart_toy_rounded,
                color: Colors.white, size: 26.r),
          ),
          Positioned(
            right: 1,
            bottom: 1,
            child: Container(
              width: 13.r,
              height: 13.r,
              decoration: BoxDecoration(
                color: customColors.doctorOnline ?? Colors.green,
                shape: BoxShape.circle,
                border: Border.all(color: colorScheme.surface, width: 2),
              ),
            ),
          ),
        ],
      );
    }

    final hasPicture = conversation.otherUserProfilePicture != null &&
        conversation.otherUserProfilePicture!.isNotEmpty;

    return Stack(
      children: [
        Container(
          width: 52.r,
          height: 52.r,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: colorScheme.primary.withValues(alpha: 0.2),
              width: 2,
            ),
          ),
          child: ClipOval(
            child: hasPicture
                ? Image.network(
                    ImageUrlHelper.getFullUrl(
                        conversation.otherUserProfilePicture),
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _placeholder(context),
                  )
                : _placeholder(context),
          ),
        ),
      ],
    );
  }

  Widget _placeholder(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      color: colorScheme.primaryContainer.withValues(alpha: 0.2),
      child: Icon(
        Icons.person_rounded,
        color: colorScheme.primary.withValues(alpha: 0.6),
        size: 28.r,
      ),
    );
  }

  Widget _buildBadge(BuildContext context, int count) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      constraints: BoxConstraints(minWidth: 20.r),
      height: 20.r,
      padding: EdgeInsets.symmetric(horizontal: 5.w),
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Center(
        child: Text(
          count > 99 ? '99+' : count.toString(),
          style: TextStyle(
            color: colorScheme.onPrimary,
            fontSize: 10.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final msgDay = DateTime(date.year, date.month, date.day);

    if (msgDay == today) return DateFormat.Hm().format(date);
    final diff = today.difference(msgDay).inDays;
    if (diff == 1) return 'Yesterday';
    if (diff < 7) return DateFormat.E().format(date); // Mon, Tue…
    return DateFormat.MMMd().format(date); // Jan 5
  }
}
