import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:doctor_appointment/core/theme/app_theme_extension.dart';

import 'package:doctor_appointment/features/chatbot/logic/chat_cubit.dart';
import 'package:doctor_appointment/features/chatbot/domain/entities/ai_chat_entity.dart';

class ChatbotView extends StatefulWidget {
  const ChatbotView({super.key});

  @override
  State<ChatbotView> createState() => _ChatbotViewState();
}

class _ChatbotViewState extends State<ChatbotView> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _showTextInputFallback = false;
  final List<String> _selectedCheckboxes = [];
  String? _selectedRadio;

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

  void _sendMessage([String? optionalText]) {
    final text = optionalText ?? _messageController.text.trim();
    if (text.isNotEmpty) {
      context.read<ChatCubit>().sendMessage(text);
      _messageController.clear();
      setState(() {
        _showTextInputFallback = false;
        _selectedCheckboxes.clear();
        _selectedRadio = null;
      });
      // Wait a bit for the optimistic message to render before scrolling
      Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
    }
  }

  Color _getRiskColor(String? riskLevel) {
    switch (riskLevel?.toUpperCase()) {
      case 'LOW':
        return Colors.green;
      case 'MEDIUM':
        return Colors.orange;
      case 'HIGH':
        return Colors.deepOrange;
      case 'EMERGENCY':
        return Colors.red;
      default:
        return Colors.transparent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 1,
        titleSpacing: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Theme.of(context).colorScheme.onSurface,
            size: 20.sp,
          ),
          onPressed: () => context.pop(),
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Icon(
                Icons.smart_toy_rounded,
                color: Theme.of(context).colorScheme.primary,
                size: 20.sp,
              ),
            ),
            SizedBox(width: 10.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AI Assistant', style: context.styleSemiBold16),
                BlocBuilder<ChatCubit, ChatState>(
                  builder: (context, state) {
                    if (state.status == ChatStatus.loading) {
                      return Text(
                        'Connecting...',
                        style: context.styleRegular12.copyWith(
                          color: Colors.orange,
                        ),
                      );
                    }
                    if (state.status == ChatStatus.sending) {
                      return Text(
                        'Typing...',
                        style: context.styleRegular12.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      );
                    }
                    return Text(
                      'Online',
                      style: context.styleRegular12.copyWith(
                        color: Theme.of(context).colorScheme.primary,
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
                backgroundColor: Theme.of(context).colorScheme.error,
                duration: const Duration(seconds: 4),
              ),
            );
          } else if (state.status == ChatStatus.ready ||
              state.status == ChatStatus.limitReached) {
            Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
          }
        },
        builder: (context, state) {
          final isLimitReached = state.status == ChatStatus.limitReached;
          final isSending =
              state.status == ChatStatus.sending ||
              state.status == ChatStatus.loading;

          return Column(
            children: [
              if (isLimitReached && state.errorMessage != null)
                Container(
                  padding: EdgeInsets.all(12.w),
                  color: Theme.of(context).colorScheme.errorContainer,
                  width: double.infinity,
                  child: Text(
                    state.errorMessage!,
                    style: context.styleRegular14.copyWith(
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                  ),
                ),
              Expanded(
                child:
                    state.status == ChatStatus.loading && state.messages.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.separated(
                        controller: _scrollController,
                        padding: EdgeInsets.all(20.w),
                        itemCount:
                            state.messages.length +
                            (state.status == ChatStatus.sending ? 1 : 0) +
                            (state.currentStructuredReport != null && !isSending
                                ? 1
                                : 0),
                        separatorBuilder: (context, index) =>
                            SizedBox(height: 16.h),
                        itemBuilder: (context, index) {
                          if (index < state.messages.length) {
                            final message = state.messages[index];
                            // The final AI message has the risk level of current state,
                            // older ones don't, since we don't store riskLevel in AIChatMessage.
                            // So we only color the very last one if it matches.
                            final isLastMessage =
                                index == state.messages.length - 1;
                            final riskColor = isLastMessage
                                ? _getRiskColor(state.currentRiskLevel)
                                : Colors.transparent;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (message.userMessage.isNotEmpty) ...[
                                  _buildUserMessage(
                                    context,
                                    message.userMessage,
                                  ),
                                  SizedBox(height: 16.h),
                                ],
                                if (message.aiMessage.isNotEmpty)
                                  _buildBotMessage(
                                    context,
                                    message.aiMessage,
                                    riskColor,
                                  ),
                              ],
                            );
                          } else if (index == state.messages.length &&
                              state.status == ChatStatus.sending) {
                            // Sending state
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (state.pendingUserMessage != null &&
                                    state.pendingUserMessage!.isNotEmpty) ...[
                                  _buildUserMessage(
                                    context,
                                    state.pendingUserMessage!,
                                  ),
                                  SizedBox(height: 16.h),
                                ],
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    padding: EdgeInsets.all(12.w),
                                    decoration: BoxDecoration(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.surface,
                                      borderRadius: BorderRadius.circular(16.r),
                                      border: Border.all(
                                        color: Theme.of(context).dividerColor,
                                      ),
                                    ),
                                    child: Text(
                                      "...",
                                      style: context.styleRegular14.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          } else {
                            // Structured Report Card
                            return _buildStructuredReport(
                              context,
                              state.currentStructuredReport!,
                            );
                          }
                        },
                      ),
              ),
              _buildInputArea(
                context,
                isSending,
                isLimitReached,
                state.currentUi,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBotMessage(BuildContext context, String text, Color riskColor) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(
            child: Container(
              margin: EdgeInsets.only(right: 50.w),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color:
                    context.customColors.chatBubbleOthers ??
                    colorScheme.surface,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.r),
                  topRight: Radius.circular(16.r),
                  bottomRight: Radius.circular(16.r),
                ),
                border: Border.all(
                  color: riskColor != Colors.transparent
                      ? riskColor
                      : theme.dividerColor,
                  width: riskColor != Colors.transparent ? 2 : 1,
                ),
              ),
              child: Text(
                text,
                style: context.styleRegular14.copyWith(
                  height: 1.5,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserMessage(BuildContext context, String text) {
    final colorScheme = Theme.of(context).colorScheme;
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: EdgeInsets.only(left: 50.w),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: context.customColors.chatBubbleMine ?? colorScheme.primary,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.r),
            topRight: Radius.circular(16.r),
            bottomLeft: Radius.circular(16.r),
          ),
        ),
        child: Text(
          text,
          style: context.styleRegular14.copyWith(
            color: colorScheme.onPrimary,
            height: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildStructuredReport(
    BuildContext context,
    Map<String, dynamic> report,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Diagnosis Report',
              style: context.styleSemiBold16.copyWith(
                color: colorScheme.primary,
              ),
            ),
            SizedBox(height: 12.h),
            if (report['summary'] != null) ...[
              Text('Summary', style: context.styleSemiBold14),
              Text(report['summary'].toString(), style: context.styleRegular14),
              SizedBox(height: 8.h),
            ],
            if (report['possibleCauses'] != null &&
                (report['possibleCauses'] as List).isNotEmpty) ...[
              Text('Possible Causes', style: context.styleSemiBold14),
              ...(report['possibleCauses'] as List).map(
                (cause) => Text('• $cause', style: context.styleRegular14),
              ),
              SizedBox(height: 8.h),
            ],
            if (report['advice'] != null &&
                (report['advice'] as List).isNotEmpty) ...[
              Text('Advice', style: context.styleSemiBold14),
              ...(report['advice'] as List).map(
                (item) => Text('• $item', style: context.styleRegular14),
              ),
              SizedBox(height: 8.h),
            ],
            if (report['whenToWorry'] != null &&
                (report['whenToWorry'] as List).isNotEmpty) ...[
              Text(
                'When to seek urgent care',
                style: context.styleSemiBold14.copyWith(color: Colors.red),
              ),
              ...(report['whenToWorry'] as List).map(
                (item) => Text('• $item', style: context.styleRegular14),
              ),
              SizedBox(height: 8.h),
            ],
            if (report['recommendedDoctors'] != null &&
                (report['recommendedDoctors'] as List).isNotEmpty) ...[
              Text('Recommended Doctors', style: context.styleSemiBold14),
              ...(report['recommendedDoctors'] as List).map(
                (doc) => Text('• $doc', style: context.styleRegular14),
              ),
              SizedBox(height: 8.h),
            ],
            if (report['risk'] != null) ...[
              Text('Risk Assessment', style: context.styleSemiBold14),
              Text(report['risk'].toString(), style: context.styleRegular14),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea(
    BuildContext context,
    bool isSending,
    bool isLimitReached,
    UiComponent? ui,
  ) {
    if (isLimitReached) {
      return _buildMessageInput(context, true, "Daily limit reached.");
    }

    if (ui == null || ui.type == 'text' || _showTextInputFallback) {
      return _buildMessageInput(
        context,
        isSending,
        isSending ? 'Wait for AI...' : 'Type your message...',
      );
    }

    if (ui.type == 'radio') {
      return _buildRadioOptions(context, ui.options, ui.allowOther, isSending);
    }

    if (ui.type == 'checkbox') {
      return _buildCheckboxOptions(
        context,
        ui.options,
        ui.allowOther,
        isSending,
      );
    }

    return _buildMessageInput(
      context,
      isSending,
      isSending ? 'Wait for AI...' : 'Type your message...',
    );
  }

  Widget _buildRadioOptions(
    BuildContext context,
    List<String> options,
    bool allowOther,
    bool isSending,
  ) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(top: BorderSide(color: theme.dividerColor)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              ...options.map(
                (option) => ChoiceChip(
                  label: Text(option),
                  selected: _selectedRadio == option,
                  onSelected: isSending
                      ? null
                      : (selected) {
                          setState(
                            () => _selectedRadio = selected ? option : null,
                          );
                          if (selected) {
                            _sendMessage(option);
                          }
                        },
                ),
              ),
              if (allowOther)
                ChoiceChip(
                  label: const Text("Other..."),
                  selected: false,
                  onSelected: isSending
                      ? null
                      : (_) {
                          setState(() => _showTextInputFallback = true);
                        },
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxOptions(
    BuildContext context,
    List<String> options,
    bool allowOther,
    bool isSending,
  ) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(top: BorderSide(color: theme.dividerColor)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              ...options.map(
                (option) => FilterChip(
                  label: Text(option),
                  selected: _selectedCheckboxes.contains(option),
                  onSelected: isSending
                      ? null
                      : (selected) {
                          setState(() {
                            if (selected) {
                              _selectedCheckboxes.add(option);
                            } else {
                              _selectedCheckboxes.remove(option);
                            }
                          });
                        },
                ),
              ),
              if (allowOther)
                ActionChip(
                  label: const Text("Other..."),
                  onPressed: isSending
                      ? null
                      : () {
                          setState(() => _showTextInputFallback = true);
                        },
                ),
            ],
          ),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: (isSending || _selectedCheckboxes.isEmpty)
                ? null
                : () {
                    _sendMessage(_selectedCheckboxes.join(', '));
                  },
            child: const Text("Submit"),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput(
    BuildContext context,
    bool isDisabled,
    String hintText,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(top: BorderSide(color: theme.dividerColor)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: TextField(
                controller: _messageController,
                enabled: !isDisabled,
                minLines: 1,
                maxLines: 4,
                expands: true, // TODO: [UI-FIX] Test it
                onSubmitted: (_) => _sendMessage(),
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: context.styleRegular14.copyWith(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          GestureDetector(
            onTap: isDisabled ? null : () => _sendMessage(),
            child: Container(
              width: 48.w,
              height: 48.h,
              decoration: BoxDecoration(
                color: isDisabled ? theme.dividerColor : colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: isDisabled && !hintText.contains("limit")
                  ? Padding(
                      padding: EdgeInsets.all(12.w),
                      child: CircularProgressIndicator(
                        color: colorScheme.onPrimary,
                        strokeWidth: 2.w,
                      ),
                    )
                  : Icon(
                      Icons.send_rounded,
                      color: colorScheme.onPrimary,
                      size: 20.sp,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
