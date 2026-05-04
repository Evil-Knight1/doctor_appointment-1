import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:doctor_appointment/core/services/service_locator.dart';
import 'package:doctor_appointment/features/chat/logic/conversations_cubit.dart';
import 'package:doctor_appointment/features/chat/logic/conversations_state.dart';
import 'package:doctor_appointment/features/chat/ui/widgets/conversation_tile.dart';
import 'package:doctor_appointment/features/chat/data/models/conversation_model.dart';
import 'package:doctor_appointment/core/utils/app_styles.dart';
import 'package:doctor_appointment/core/utils/routes.dart';
import 'package:go_router/go_router.dart';

class ConversationsScreen extends StatelessWidget {
  const ConversationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ConversationsCubit>()..fetchConversations(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Chats', style: AppTextStyles.headingLarge),
          centerTitle: true,
        ),
        body: BlocBuilder<ConversationsCubit, ConversationsState>(
          builder: (context, state) {
            if (state.status == ConversationsStatus.loading && state.conversations.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            final conversations = state.conversations;

            return ListView.separated(
              itemCount: conversations.length + 1, // +1 for AI Chat
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                if (index == 0) {
                  // AI Chat Entry
                  return ConversationTile(
                    conversation: ConversationModel(
                      otherUserId: -1, // Dummy ID
                      otherUserName: 'AI Health Assistant',
                      otherUserRole: 'AI',
                      unreadCount: 0,
                      lastMessage: 'Your smart health companion',
                      lastMessageTime: DateTime.now(),
                    ),
                    onTap: () {
                      context.pushNamed(Routes.chatHistoryView);
                    },
                  );
                }

                final conversation = conversations[index - 1];
                return ConversationTile(
                  conversation: conversation,
                  onTap: () {
                    context.push('/chat/${conversation.otherUserId}', extra: conversation.otherUserName);
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
