import 'package:doctor_appointment/core/theme/app_theme_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:doctor_appointment/core/utils/app_styles.dart';
import 'package:doctor_appointment/features/chat/data/models/chat_message_model.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessageModel message;
  final bool isMe;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isMe,
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
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
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
                    EdgeInsets.symmetric(vertical: 10.h, horizontal: 14.w),
                decoration: BoxDecoration(
                  gradient: isMe
                      ? LinearGradient(
                          colors: [
                            customColors.chatBubbleMineGradientStart!,
                            customColors.chatBubbleMineGradientEnd!,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: isMe ? null : customColors.chatBubbleOthers,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(18.r),
                    topRight: Radius.circular(18.r),
                    bottomLeft: Radius.circular(isMe ? 18.r : 4.r),
                    bottomRight: Radius.circular(isMe ? 4.r : 18.r),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isMe
                          ? colorScheme.primary.withValues(alpha: 0.25)
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
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _formatTime(message.timestamp),
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: isMe
                                ? Colors.white.withValues(alpha: 0.75)
                                : colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (isMe) ...[
                          SizedBox(width: 4.w),
                          Icon(
                            Icons.done_all_rounded,
                            size: 14.r,
                            color: Colors.white.withValues(alpha: 0.8),
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
    );
  }

  Widget _senderDot(BuildContext context) {
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
}

