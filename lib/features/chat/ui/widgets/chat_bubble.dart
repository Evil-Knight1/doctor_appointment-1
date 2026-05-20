import 'package:doctor_appointment/core/theme/app_theme_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:doctor_appointment/core/utils/image_url_helper.dart';
import 'package:doctor_appointment/features/chat/data/models/chat_message_model.dart';
import 'package:doctor_appointment/features/chat/logic/user_chat_cubit.dart';
class ChatBubble extends StatelessWidget {
  final ChatMessageModel message;
  final bool isMe;
  final String? otherUserProfilePicture;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.otherUserProfilePicture,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final customColors = context.customColors;
    return Padding(
      padding: EdgeInsets.only(
        top: 2.h,
        bottom: 2.h,
        left: isMe ? 60.w : 0,
        right: isMe ? 0 : 60.w,
      ),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Align(
            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
            child: GestureDetector(
              onTap: message.isFailed
                  ? () => context.read<UserChatCubit>().retryMessage(message)
                  : null,
              onLongPress: !isMe ? () => _showReportMenu(context) : null,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (!isMe) ...[
                    _senderDot(context),
                    SizedBox(width: 6.w),
                  ],
                  Flexible(
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
                      decoration: BoxDecoration(
                        gradient: isMe
                            ? LinearGradient(
                                colors: message.isFailed 
                                  ? [colorScheme.error.withValues(alpha: 0.8), colorScheme.error]
                                  : [
                                      customColors.chatBubbleMineGradientStart!,
                                      customColors.chatBubbleMineGradientEnd!,
                                    ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
                        color: isMe ? null : customColors.chatBubbleOthers,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20.r),
                          topRight: Radius.circular(20.r),
                          bottomLeft: Radius.circular(isMe ? 20.r : 4.r),
                          bottomRight: Radius.circular(isMe ? 4.r : 20.r),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isMe
                                ? (message.isFailed ? colorScheme.error : colorScheme.primary).withValues(alpha: 0.25)
                                : colorScheme.shadow.withValues(alpha: 0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: isMe
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            message.message,
                            style: context.bodyMedium.copyWith(
                              color:
                                  isMe ? Colors.white : colorScheme.onSurface,
                              height: 1.4,
                              fontSize: 15.sp,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _formatTime(message.timestamp),
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: isMe
                                      ? Colors.white.withValues(alpha: 0.75)
                                      : colorScheme.onSurfaceVariant,
                                ),
                              ),
                              if (isMe) ...[
                                SizedBox(width: 4.w),
                                Icon(
                                  message.isFailed 
                                      ? Icons.error_outline_rounded 
                                      : (message.isRead ? Icons.done_all_rounded : Icons.done_rounded),
                                  size: 15.r,
                                  color: message.isFailed
                                      ? Colors.white
                                      : Colors.white.withValues(alpha: message.isRead ? 0.95 : 0.6),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (message.isFailed)
            Padding(
              padding: EdgeInsets.only(top: 4.h, right: 8.w),
              child: GestureDetector(
                onTap: () => context.read<UserChatCubit>().retryMessage(message),
                child: Text(
                  'Failed to send. Tap to retry',
                  style: context.labelSmall?.copyWith(
                    color: colorScheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _senderDot(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (otherUserProfilePicture != null && otherUserProfilePicture!.isNotEmpty) {
      return Container(
        width: 28.r,
        height: 28.r,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
              color: colorScheme.primary.withValues(alpha: 0.2), width: 1.5),
        ),
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: ImageUrlHelper.getFullUrl(otherUserProfilePicture),
            httpHeaders: ImageUrlHelper.getImageHeaders(),
            fit: BoxFit.cover,
            errorWidget: (context, url, error) => _buildPlaceholderDot(context),
          ),
        ),
      );
    }
    return _buildPlaceholderDot(context);
  }

  Widget _buildPlaceholderDot(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: 28.r,
      height: 28.r,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colorScheme.primaryContainer,
        border: Border.all(
            color: colorScheme.primary.withValues(alpha: 0.2), width: 1.5),
      ),
      child: Icon(Icons.person_rounded,
          color: colorScheme.onPrimaryContainer.withValues(alpha: 0.7), size: 16.r),
    );
  }

  String _formatTime(DateTime timestamp) {
    return '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
  }

  void _showReportMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) => _buildReportMenu(context, bottomSheetContext),
    );
  }

  Widget _buildReportMenu(BuildContext context, BuildContext bottomSheetContext) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 8.h),
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 16.h),
            ListTile(
              leading: Icon(Icons.report_problem_outlined, color: colorScheme.error),
              title: Text(
                'Report Message',
                style: TextStyle(color: colorScheme.error, fontWeight: FontWeight.w600),
              ),
              onTap: () {
                Navigator.pop(bottomSheetContext);
                _showReportDialog(context);
              },
            ),
            SizedBox(height: 8.h),
          ],
        ),
      ),
    );
  }

  void _showReportDialog(BuildContext parentContext) {
    final reasonController = TextEditingController();
    final colorScheme = Theme.of(parentContext).colorScheme;

    showDialog(
      context: parentContext,
      builder: (dialogContext) {
        bool isSubmitting = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
              title: const Text('Report Message'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Please provide a reason for reporting this message:'),
                  SizedBox(height: 16.h),
                  TextField(
                    controller: reasonController,
                    maxLines: 3,
                    maxLength: 500,
                    decoration: InputDecoration(
                      hintText: 'Enter your reason here...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(color: colorScheme.primary, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting ? null : () => Navigator.pop(dialogContext),
                  child: Text('Cancel', style: TextStyle(color: colorScheme.onSurfaceVariant)),
                ),
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          final reason = reasonController.text.trim();
                          if (reason.length < 5) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Reason must be at least 5 characters.', style: TextStyle(color: colorScheme.onError)),
                                backgroundColor: colorScheme.error,
                              ),
                            );
                            return;
                          }

                          setState(() => isSubmitting = true);

                          try {
                            await parentContext.read<UserChatCubit>().reportMessage(message.id, reason);
                            if (dialogContext.mounted) {
                              Navigator.pop(dialogContext);
                              ScaffoldMessenger.of(parentContext).showSnackBar(
                                const SnackBar(content: Text('Message reported successfully.')),
                              );
                            }
                          } catch (e) {
                            setState(() => isSubmitting = false);
                            if (dialogContext.mounted) {
                              ScaffoldMessenger.of(parentContext).showSnackBar(
                                SnackBar(content: Text('Failed to report: $e'), backgroundColor: colorScheme.error),
                              );
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.error,
                    foregroundColor: colorScheme.onError,
                  ),
                  child: isSubmitting
                      ? SizedBox(width: 16.w, height: 16.h, child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Report'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

