import 'package:doctor_appointment/core/utils/app_styles.dart';
import 'package:doctor_appointment/core/utils/go_router.dart';
import 'package:doctor_appointment/features/chatbot/logic/chat_history_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ChatHistoryView extends StatelessWidget {
  const ChatHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: Icon(Icons.arrow_back_ios_new_rounded,
                    color: colorScheme.onSurface, size: 20.sp),
                onPressed: () => context.pop(),
              )
            : null,
        title: Text(
          'Chat Assistant',
          style: AppStyles.styleSemiBold22.copyWith(fontSize: 18.sp),
        ),
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 80.h),
        child: FloatingActionButton.extended(
          onPressed: () => context.push(AppRouter.kChatbotView),
          backgroundColor: colorScheme.primary,
          icon: Icon(Icons.add_rounded, color: colorScheme.onPrimary),
          label: Text('New Chat',
              style: AppStyles.styleMedium14.copyWith(color: colorScheme.onPrimary)),
        ),
      ),
      body: BlocBuilder<ChatHistoryCubit, ChatHistoryState>(
        builder: (context, state) {
          final isLoading = state is ChatHistoryLoading;
          final sessionIds = state is ChatHistoryLoaded ? state.sessionIds : [];

          if (state is ChatHistoryError) {
            return Center(
              child: Text(
                state.message,
                style: AppStyles.styleMedium14.copyWith(color: colorScheme.error),
              ),
            );
          }

          if (state is ChatHistoryLoaded && sessionIds.isEmpty) {
            return Padding(
              padding: EdgeInsets.only(bottom: 100.h),
              child: Center(
                child: Text('No previous chats found.',
                    style: AppStyles.styleMedium14),
              ),
            );
          }

          return Skeletonizer(
            enabled: isLoading,
            child: ListView.separated(
              padding: EdgeInsets.only(
                left: 20.w,
                right: 20.w,
                top: 16.h,
                bottom: 100.h,
              ),
              itemCount: isLoading ? 6 : sessionIds.length,
              separatorBuilder: (context, index) => SizedBox(height: 12.h),
              itemBuilder: (context, index) {
                return _buildChatRecord(
                  context,
                  isLoading ? 'dummy_session_id' : sessionIds[index],
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildChatRecord(BuildContext context, String sessionId) {
    // We only have the session ID from the backend currently.
    // In a real app we might have a title, but we will show the truncated session ID.
    final displayTitle = 'Chat Session ${sessionId.substring(0, 8)}...';
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return GestureDetector(
      onTap: () {
        context.push(AppRouter.kChatbotView, extra: sessionId);
      },
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: theme.dividerColor),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              height: 48.h,
              width: 48.w,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.smart_toy_rounded, color: colorScheme.primary, size: 24.sp),
            ),
            SizedBox(width: 16.w),
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
                          style: AppStyles.styleSemiBold16.copyWith(
                            color: colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Tap to continue conversation',
                    style: AppStyles.styleMedium14.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
