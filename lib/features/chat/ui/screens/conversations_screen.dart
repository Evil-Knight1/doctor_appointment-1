import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:doctor_appointment/core/services/service_locator.dart';
import 'package:doctor_appointment/features/chat/logic/conversations_cubit.dart';
import 'package:doctor_appointment/features/chat/logic/conversations_state.dart';
import 'package:doctor_appointment/features/chat/ui/widgets/conversation_tile.dart';
import 'package:doctor_appointment/features/chat/data/models/conversation_model.dart';
import 'package:doctor_appointment/core/theme/app_theme_extension.dart';
import 'package:doctor_appointment/core/utils/app_styles.dart';
import 'package:doctor_appointment/core/utils/routes.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({super.key});

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return BlocProvider(
      create: (context) => getIt<ConversationsCubit>()..fetchConversations(),
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        body: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: LiquidPullToRefresh(
                onRefresh: () =>
                    context.read<ConversationsCubit>().fetchConversations(),
                color: colorScheme.primary,
                backgroundColor: colorScheme.surface,
                showChildOpacityTransition: false,
                child: BlocBuilder<ConversationsCubit, ConversationsState>(
                  builder: (context, state) {
                    if (state.status == ConversationsStatus.loading &&
                        state.conversations.isEmpty) {
                      return Skeletonizer(
                        enabled: true,
                        child: ListView.builder(
                          padding: EdgeInsets.only(top: 8.h, bottom: 24.h),
                          itemCount: 10,
                          itemBuilder: (context, index) {
                            return ConversationTile(
                              conversation: ConversationModel(
                                otherUserId: index,
                                otherUserName: 'User Name Loading',
                                otherUserRole: 'Doctor',
                                unreadCount: 0,
                                lastMessage:
                                    'This is a loading message placeholder',
                                lastMessageTime: DateTime.now(),
                              ),
                              onTap: () {},
                            );
                          },
                        ),
                      );
                    }

                    final all = state.conversations;
                    final filtered = _query.isEmpty
                        ? all
                        : all
                              .where(
                                (c) => c.otherUserName.toLowerCase().contains(
                                  _query.toLowerCase(),
                                ),
                              )
                              .toList();

                    // AI entry + filtered real conversations
                    final bool showAi =
                        _query.isEmpty ||
                        'ai health assistant'.contains(_query.toLowerCase());

                    final int total = filtered.length + (showAi ? 1 : 0);

                    if (total == 0) {
                      return _buildEmpty(context);
                    }

                    return ListView.builder(
                      padding: EdgeInsets.only(top: 8.h, bottom: 24.h),
                      itemCount: total,
                      itemBuilder: (context, index) {
                        if (showAi && index == 0) {
                          return ConversationTile(
                            conversation: ConversationModel(
                              otherUserId: -1,
                              otherUserName: 'AI Health Assistant',
                              otherUserRole: 'AI',
                              unreadCount: 0,
                              lastMessage: 'Your smart health companion',
                              lastMessageTime: DateTime.now(),
                            ),
                            isAi: true,
                            onTap: () =>
                                context.pushNamed(Routes.chatHistoryView),
                          );
                        }
                        final conversation =
                            filtered[showAi ? index - 1 : index];
                        return ConversationTile(
                          conversation: conversation,
                          onTap: () => context.push(
                            '/chat/${conversation.otherUserId}',
                            extra: conversation.otherUserName,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final customColors = context.customColors;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            customColors.chatBubbleMineGradientStart ?? Colors.blue,
            customColors.chatBubbleMineGradientEnd ?? Colors.blueAccent,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const BackButton(color: Colors.white),
                  const Spacer(),
                  Text(
                    'Messages',
                    style: context.headingLarge.copyWith(
                      color: Colors.white,
                      fontSize: 20.sp,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(width: 40.w),
                ],
              ),
              SizedBox(height: 16.h),
              // Search bar
              Container(
                height: 44.h,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _query = v),
                  style: TextStyle(color: Colors.white, fontSize: 14.sp),
                  decoration: InputDecoration(
                    hintText: 'Search conversations…',
                    hintStyle: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 14.sp,
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: Colors.white.withValues(alpha: 0.7),
                      size: 20,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.chat_bubble_outline_rounded,
            size: 64.r,
            color: colorScheme.onSurfaceVariant,
          ),
          SizedBox(height: 12.h),
          Text(
            'No conversations found',
            style: context.bodyMedium.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

}
