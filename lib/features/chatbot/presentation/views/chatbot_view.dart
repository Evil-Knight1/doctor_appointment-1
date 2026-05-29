import 'package:doctor_appointment/core/widgets/glass_alert_error.dart';
import 'package:doctor_appointment/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:doctor_appointment/core/theme/app_theme_extension.dart';

import 'package:doctor_appointment/features/chatbot/domain/entities/ai_chat_entity.dart';
import 'package:doctor_appointment/features/chatbot/logic/chat_cubit.dart';

import 'package:doctor_appointment/features/chatbot/presentation/widgets/chatbot_checkbox_selector.dart';
import 'package:doctor_appointment/features/chatbot/presentation/widgets/chatbot_radio_selector.dart';

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
  void initState() {
    super.initState();
  }

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

  void _resetSelections() {
    _selectedCheckboxes.clear();
    _selectedRadio = null;
    _showTextInputFallback = false;
  }

  void _sendMessage([String? optionalText]) {
    final text = optionalText ?? _messageController.text.trim();

    if (text.isEmpty) return;

    context.read<ChatCubit>().sendMessage(text);

    _messageController.clear();

    setState(_resetSelections);

    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
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
    final AppLocalizations _appLocalizations = AppLocalizations.of(context)!;
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
                Text(
                  _appLocalizations.aiAssistant,
                  style: context.styleSemiBold16,
                ),

                BlocBuilder<ChatCubit, ChatState>(
                  builder: (context, state) {
                    if (state.status == ChatStatus.loading) {
                      return Text(
                        _appLocalizations.connecting,
                        style: context.styleRegular12.copyWith(
                          color: Colors.orange,
                        ),
                      );
                    }

                    if (state.status == ChatStatus.sending) {
                      return Text(
                        _appLocalizations.typing,
                        style: context.styleRegular12.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      );
                    }

                    return Text(
                      _appLocalizations.online,
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
              ),
            );
          }
          if (state.status == ChatStatus.limitReached) {
            GlassAlert.show(
              context,
              title: _appLocalizations.limitReached,
              message: _appLocalizations.limitReachedMessage,
              icon: Icons.warning_rounded,
              iconColor: Colors.orange,
              duration: const Duration(seconds: 4),
            );
          }

          if (state.status == ChatStatus.ready) {
            Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
          }
        },

        builder: (context, state) {
          final isSending =
              state.status == ChatStatus.sending ||
              state.status == ChatStatus.loading;

          final isLimitReached = state.status == ChatStatus.limitReached;

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

                        separatorBuilder: (_, _) => SizedBox(height: 16.h),

                        itemBuilder: (context, index) {
                          if (index < state.messages.length) {
                            final message = state.messages[index];

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
                          }
                          return Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              padding: EdgeInsets.all(12.w),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                              child: Text("...", style: context.styleRegular14),
                            ),
                          );
                        },
                      ),
              ),

              _buildInputArea(
                context,
                _appLocalizations,
                state.currentUi,
                isSending,
                isLimitReached,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInputArea(
    BuildContext context,
    AppLocalizations appLocalizations,
    UiComponent? ui,
    bool isSending,
    bool isLimitReached,
  ) {
    if (isLimitReached) {
      return _buildMessageInput(
        context,
        true,
        appLocalizations.limitReachedMessage,
      );
    }

    if (ui == null || ui.type == 'text' || _showTextInputFallback) {
      return _buildMessageInput(
        context,
        isSending,
        isSending
            ? appLocalizations.waitingForAi
            : appLocalizations.typeYourMessage,
      );
    }

    if (ui.type == 'radio') {
      return ChatbotRadioSelector(
        options: ui.options,
        selectedValue: _selectedRadio,
        isLoading: isSending,
        allowOther: ui.allowOther,

        onChanged: (value) {
          setState(() {
            _selectedRadio = value;
          });
        },

        onSubmit: () {
          _sendMessage(_selectedRadio);
        },

        onOtherTap: () {
          setState(() {
            _showTextInputFallback = true;
          });
        },
      );
    }

    if (ui.type == 'checkbox') {
      return ChatbotCheckboxSelector(
        options: ui.options,
        selectedValues: _selectedCheckboxes,
        isLoading: isSending,
        allowOther: ui.allowOther,

        onChanged: (value) {
          setState(() {
            if (_selectedCheckboxes.contains(value)) {
              _selectedCheckboxes.remove(value);
            } else {
              _selectedCheckboxes.add(value);
            }
          });
        },

        onSubmit: () {
          _sendMessage(_selectedCheckboxes.join(', '));
        },

        onOtherTap: () {
          setState(() {
            _showTextInputFallback = true;
          });
        },
      );
    }

    return _buildMessageInput(
      context,
      isSending,
      appLocalizations.typeYourMessage,
    );
  }

  Widget _buildBotMessage(BuildContext context, String text, Color riskColor) {
    final theme = Theme.of(context);

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(right: 50.w),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color:
              context.customColors.chatBubbleOthers ??
              theme.colorScheme.surface,

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
        child: Text(text, style: context.styleRegular14.copyWith(height: 1.5)),
      ),
    );
  }

  Widget _buildUserMessage(BuildContext context, String text) {
    final theme = Theme.of(context);

    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: EdgeInsets.only(left: 50.w),

        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),

        decoration: BoxDecoration(
          color:
              context.customColors.chatBubbleMine ?? theme.colorScheme.primary,

          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.r),
            topRight: Radius.circular(16.r),
            bottomLeft: Radius.circular(16.r),
          ),
        ),

        child: Text(
          text,
          style: context.styleRegular14.copyWith(
            color: theme.colorScheme.onPrimary,
            height: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildMessageInput(
    BuildContext context,
    bool isDisabled,
    String hintText,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),

      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
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

                onSubmitted: (_) => _sendMessage(),

                decoration: InputDecoration(
                  hintText: hintText,
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
                color: isDisabled
                    ? theme.dividerColor
                    : theme.colorScheme.primary,

                shape: BoxShape.circle,
              ),

              child: Icon(
                Icons.send_rounded,
                color: theme.colorScheme.onPrimary,
                size: 20.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
