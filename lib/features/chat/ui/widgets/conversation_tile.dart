import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:doctor_appointment/core/utils/app_colors.dart';
import 'package:doctor_appointment/core/utils/app_styles.dart';
import 'package:doctor_appointment/features/chat/data/models/conversation_model.dart';
import 'package:intl/intl.dart';

class ConversationTile extends StatelessWidget {
  final ConversationModel conversation;
  final VoidCallback onTap;

  const ConversationTile({
    super.key,
    required this.conversation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      leading: CircleAvatar(
        radius: 28.r,
        backgroundColor: AppColors.gray200,
        backgroundImage: conversation.otherUserProfilePicture != null
            ? NetworkImage(conversation.otherUserProfilePicture!)
            : null,
        child: conversation.otherUserProfilePicture == null
            ? Icon(Icons.person, color: AppColors.gray100)
            : null,
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              conversation.otherUserName,
              style: AppTextStyles.headingMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            _formatDate(conversation.lastMessageTime),
            style: AppTextStyles.bodySmall.copyWith(fontSize: 10.sp),
          ),
        ],
      ),
      subtitle: Padding(
        padding: EdgeInsets.only(top: 4.h),
        child: Row(
          children: [
            Expanded(
              child: Text(
                conversation.lastMessage,
                style: AppTextStyles.bodySmall.copyWith(
                  color: conversation.unreadCount > 0
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                  fontWeight: conversation.unreadCount > 0
                      ? FontWeight.w600
                      : FontWeight.w400,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (conversation.unreadCount > 0)
              Container(
                margin: EdgeInsets.only(left: 8.w),
                padding: EdgeInsets.all(6.r),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  conversation.unreadCount.toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return DateFormat.Hm().format(date);
    }
    return DateFormat.yMd().format(date);
  }
}
