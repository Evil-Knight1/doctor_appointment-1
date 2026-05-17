import 'package:cached_network_image/cached_network_image.dart';
import 'package:doctor_appointment/core/utils/image_url_helper.dart';
import 'package:doctor_appointment/core/theme/app_theme_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:doctor_appointment/core/services/service_locator.dart';
import 'package:doctor_appointment/features/chat/logic/user_chat_cubit.dart';
import 'package:doctor_appointment/features/chat/logic/chat_state.dart';
import 'package:doctor_appointment/features/chat/ui/widgets/chat_bubble.dart';
class ChatScreen extends StatefulWidget {
  final int otherUserId;
  final String otherUserName;
  final String? otherUserProfilePicture;

  const ChatScreen({
    super.key,
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserProfilePicture,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late final AnimationController _sendButtonController;

  @override
  void initState() {
    super.initState();
    _sendButtonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _messageController.addListener(() {
      if (_messageController.text.trim().isNotEmpty) {
        _sendButtonController.forward();
      } else {
        _sendButtonController.reverse();
      }
    });
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return BlocProvider(
      create: (context) => getIt<UserChatCubit>()
        ..connect()
        ..fetchChatHistory(widget.otherUserId),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: _buildAppBar(context),
        body: Column(
          children: [
            Expanded(
              child: BlocConsumer<UserChatCubit, ChatState>(
                listener: (context, state) {
                  if (state.errorMessage != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.errorMessage!),
                        backgroundColor: colorScheme.error,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r)),
                      ),
                    );
                  }
                  WidgetsBinding.instance
                      .addPostFrameCallback((_) => _scrollToBottom());
                },
                builder: (context, state) {
                  if (state.status == ChatStatus.loading &&
                      state.messages.isEmpty) {
                    return Center(
                      child: CircularProgressIndicator(
                          color: colorScheme.primary, strokeWidth: 2.5),
                    );
                  }

                  final messages = state.messages;

                  if (messages.isEmpty) {
                    return _buildEmptyState(context);
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    padding:
                        EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isMe = message.senderId != widget.otherUserId;

                      // Date divider between days
                      final showDateDivider = index == 0 ||
                          !_isSameDay(messages[index - 1].timestamp,
                              message.timestamp);

                      return Column(
                        children: [
                          if (showDateDivider) _buildDateDivider(context, message.timestamp),
                          ChatBubble(
                            message: message,
                            isMe: isMe,
                            otherUserProfilePicture: widget.otherUserProfilePicture,
                          ),
                        ],
                      );
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

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final customColors = context.customColors;
    return AppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.95),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shadowColor: colorScheme.shadow.withValues(alpha: 0.1),
      flexibleSpace: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.95),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new_rounded,
            color: colorScheme.onSurface, size: 18),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          widget.otherUserProfilePicture != null &&
                  widget.otherUserProfilePicture!.isNotEmpty
              ? Container(
                  width: 38.r,
                  height: 38.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: colorScheme.primary.withValues(alpha: 0.2),
                      width: 1.5,
                    ),
                  ),
                  child: ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: ImageUrlHelper.getFullUrl(
                        widget.otherUserProfilePicture,
                      ),
                      httpHeaders: ImageUrlHelper.getImageHeaders(),
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) =>
                          _buildPlaceholderAvatar(context, customColors),
                    ),
                  ),
                )
              : _buildPlaceholderAvatar(context, customColors),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.otherUserName,
                  style: context.headingMedium.copyWith(
                    fontSize: 15.sp,
                    color: colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                BlocBuilder<UserChatCubit, ChatState>(
                  builder: (context, state) => Row(
                    children: [
                      Container(
                        width: 6.r,
                        height: 6.r,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: state.isConnected
                              ? customColors.doctorOnline
                              : customColors.warning,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        state.isConnected ? 'Online' : 'Connecting…',
                        style: context.bodySmall.copyWith(
                          fontSize: 11.sp,
                          color: state.isConnected
                              ? (customColors.doctorOnline ?? Colors.green)
                              : (customColors.warning ?? Colors.orange),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.waving_hand_rounded, size: 56.r, color: colorScheme.onSurfaceVariant),
          SizedBox(height: 12.h),
          Text(
            'Say hello to ${widget.otherUserName}!',
            style: context.bodyMedium
                .copyWith(color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildDateDivider(BuildContext context, DateTime date) {
    final colorScheme = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final msgDay = DateTime(date.year, date.month, date.day);
    final diff = today.difference(msgDay).inDays;

    String label;
    if (diff == 0) {
      label = 'Today';
    } else if (diff == 1) {
      label = 'Yesterday';
    } else {
      label =
          '${date.day} ${_monthName(date.month)} ${date.year != now.year ? date.year : ''}';
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageInput(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final customColors = context.customColors;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(24.r),
                    border: Border.all(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.5), 
                      width: 1
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SizedBox(width: 12.w),
                      Expanded(
                        child: BlocBuilder<UserChatCubit, ChatState>(
                          builder: (context, state) => TextField(
                            controller: _messageController,
                            maxLines: 5,
                            minLines: 1,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: InputDecoration(
                              hintText: 'Type a message…',
                              hintStyle: context.bodyMedium.copyWith(
                                  color: colorScheme.onSurfaceVariant),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 4.w, vertical: 12.h),
                            ),
                            style: context.bodyMedium
                                .copyWith(color: colorScheme.onSurface),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.attach_file_rounded, 
                            color: colorScheme.onSurfaceVariant, size: 22.r),
                        onPressed: () {}, // Add attachment placeholder
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              BlocBuilder<UserChatCubit, ChatState>(
                builder: (context, state) {
                  return AnimatedBuilder(
                    animation: _sendButtonController,
                    builder: (_, _) => GestureDetector(
                      onTap: () => _sendMessage(context),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 48.r,
                        height: 48.r,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: state.isConnected
                                ? [
                                    customColors.chatBubbleMineGradientStart!,
                                    customColors.chatBubbleMineGradientEnd!,
                                  ]
                                : [Colors.grey, Colors.grey.shade600],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: state.isConnected
                              ? [
                                  BoxShadow(
                                    color: colorScheme.primary
                                        .withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  )
                                ]
                              : null,
                        ),
                        child: Icon(
                          _messageController.text.trim().isEmpty 
                              ? Icons.mic_rounded 
                              : Icons.send_rounded,
                          color: Colors.white, 
                          size: 22.r,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
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

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _monthName(int month) {
    const names = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return names[month];
  }

  Widget _buildPlaceholderAvatar(BuildContext context, dynamic customColors) {
    return Container(
      width: 38.r,
      height: 38.r,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            customColors.chatBubbleMineGradientStart!,
            customColors.chatBubbleMineGradientEnd!,
          ],
        ),
      ),
      child: Center(
        child: Text(
          widget.otherUserName.isNotEmpty
              ? widget.otherUserName[0].toUpperCase()
              : '?',
          style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _sendButtonController.dispose();
    super.dispose();
  }
}
