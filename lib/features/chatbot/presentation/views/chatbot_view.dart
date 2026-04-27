import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:doctor_appointment/core/utils/app_colors.dart';
import 'package:doctor_appointment/core/utils/app_styles.dart';
import 'package:doctor_appointment/features/chatbot/logic/chat_cubit.dart';

class ChatbotView extends StatefulWidget {
  const ChatbotView({super.key});

  @override
  State<ChatbotView> createState() => _ChatbotViewState();
}

class _ChatbotViewState extends State<ChatbotView> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isNotEmpty) {
      context.read<ChatCubit>().sendMessage(text);
      _messageController.clear();
      // Wait a bit for the optimistic message to render before scrolling
      Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        titleSpacing: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary,
            size: 20.sp,
          ),
          onPressed: () => context.pop(),
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.primaryLight,
              child: Icon(
                Icons.smart_toy_rounded,
                color: AppColors.primary,
                size: 20.sp,
              ),
            ),
            SizedBox(width: 10.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AI Assistant', style: AppStyles.styleSemiBold16),
                BlocBuilder<ChatCubit, ChatState>(
                  builder: (context, state) {
                    if (state.status == ChatStatus.loading) {
                      return Text(
                        'Connecting...',
                        style: AppStyles.styleRegular12.copyWith(
                          color: Colors.orange,
                        ),
                      );
                    }
                    if (state.status == ChatStatus.sending) {
                      return Text(
                        'Typing...',
                        style: AppStyles.styleRegular12.copyWith(
                          color: AppColors.primary,
                        ),
                      );
                    }
                    return Text(
                      'Online',
                      style: AppStyles.styleRegular12.copyWith(
                        color: AppColors.primary,
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      body: BlocConsumer<ChatCubit, ChatState>(
        listener: (context, state) {
          if (state.status == ChatStatus.error && state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 4),
              ),
            );
          } else if (state.status == ChatStatus.ready) {
            Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              Expanded(
                child:
                    state.status == ChatStatus.loading && state.messages.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.separated(
                        controller: _scrollController,
                        padding: EdgeInsets.all(20.w),
                        itemCount:
                            state.messages.length +
                            (state.status == ChatStatus.sending ? 1 : 0),
                        separatorBuilder: (context, index) =>
                            SizedBox(height: 16.h),
                        itemBuilder: (context, index) {
                          if (index < state.messages.length) {
                            final message = state.messages[index];
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildUserMessage(message.userMessage),
                                SizedBox(height: 16.h),
                                _buildBotMessage(message.aiMessage),
                              ],
                            );
                          } else {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (state.pendingUserMessage != null) ...[
                                  _buildUserMessage(state.pendingUserMessage!),
                                  SizedBox(height: 16.h),
                                ],
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    padding: EdgeInsets.all(12.w),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16.r),
                                      border: Border.all(
                                        color: AppColors.border,
                                      ),
                                    ),
                                    child: Text(
                                      "...",
                                      style: AppStyles.styleRegular14.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }
                        },
                      ),
              ),
              _buildMessageInput(
                state.status == ChatStatus.sending ||
                    state.status == ChatStatus.loading,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBotMessage(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(right: 50.w),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.r),
            topRight: Radius.circular(16.r),
            bottomRight: Radius.circular(16.r),
          ),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(
          text,
          style: AppStyles.styleRegular14.copyWith(height: 1.5),
        ),
      ),
    );
  }

  Widget _buildUserMessage(String text) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: EdgeInsets.only(left: 50.w),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.r),
            topRight: Radius.circular(16.r),
            bottomLeft: Radius.circular(16.r),
          ),
        ),
        child: Text(
          text,
          style: AppStyles.styleRegular14.copyWith(
            color: Colors.white,
            height: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildMessageInput(bool isSending) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: AppColors.bg,
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: TextField(
                controller: _messageController,
                enabled: !isSending,
                onSubmitted: (_) => _sendMessage(),
                decoration: InputDecoration(
                  hintText: isSending
                      ? 'Wait for AI...'
                      : 'Type your message...',
                  hintStyle: AppStyles.styleRegular14.copyWith(
                    color: AppColors.textLight,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          GestureDetector(
            onTap: isSending ? null : _sendMessage,
            child: Container(
              width: 48.w,
              height: 48.h,
              decoration: BoxDecoration(
                color: isSending ? AppColors.border : AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: isSending
                  ? Padding(
                      padding: EdgeInsets.all(12.w),
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.w,
                      ),
                    )
                  : Icon(Icons.send_rounded, color: Colors.white, size: 20.sp),
            ),
          ),
        ],
      ),
    );
  }
}
