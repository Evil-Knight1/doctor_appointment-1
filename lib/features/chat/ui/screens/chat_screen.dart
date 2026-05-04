import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:doctor_appointment/core/services/service_locator.dart';
import 'package:doctor_appointment/features/chat/logic/user_chat_cubit.dart';
import 'package:doctor_appointment/features/chat/logic/chat_state.dart';
import 'package:doctor_appointment/features/chat/ui/widgets/chat_bubble.dart';
import 'package:doctor_appointment/core/utils/app_colors.dart';
import 'package:doctor_appointment/core/utils/app_styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChatScreen extends StatefulWidget {
  final int otherUserId;
  final String otherUserName;

  const ChatScreen({
    super.key,
    required this.otherUserId,
    required this.otherUserName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<UserChatCubit>()
        ..connect()
        ..fetchChatHistory(widget.otherUserId),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.otherUserName, style: AppTextStyles.headingMedium),
              BlocBuilder<UserChatCubit, ChatState>(
                builder: (context, state) {
                  return Text(
                    state.isConnected ? 'Online' : 'Connecting...',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: state.isConnected ? Colors.green : Colors.orange,
                    ),
                  );
                },
              ),
            ],
          ),
          elevation: 0,
          backgroundColor: Colors.white,
          iconTheme: const IconThemeData(color: AppColors.textPrimary),
        ),
        body: Column(
          children: [
            Expanded(
              child: BlocConsumer<UserChatCubit, ChatState>(
                listener: (context, state) {
                  if (state.errorMessage != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.errorMessage!)),
                    );
                  }
                  WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
                },
                builder: (context, state) {
                  if (state.status == ChatStatus.loading && state.messages.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final messages = state.messages;

                  if (messages.isEmpty) {
                    return Center(
                      child: Text('No messages yet', style: AppTextStyles.bodySmall),
                    );
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 8.w),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isMe = message.senderId != widget.otherUserId;
                      return ChatBubble(message: message, isMe: isMe);
                    },
                  );
                },
              ),
            ),
            _buildMessageInput(context),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Builder(
                builder: (innerContext) => TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24.r),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: AppColors.gray100,
                    contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                  ),
                  maxLines: null,
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
                ),
              ),
            ),
            SizedBox(width: 8.w),
            BlocBuilder<UserChatCubit, ChatState>(
              builder: (context, state) {
                return GestureDetector(
                  onTap: () => _sendMessage(context),
                  child: Container(
                    padding: EdgeInsets.all(12.r),
                    decoration: BoxDecoration(
                      color: state.isConnected ? AppColors.primary : Colors.grey,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.send, color: Colors.white, size: 20),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage(BuildContext context) {
    final text = _messageController.text.trim();
    if (text.isNotEmpty) {
      context.read<UserChatCubit>().sendMessage(text);
      _messageController.clear();
      _scrollToBottom();
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
