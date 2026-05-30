import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:doctor_appointment/features/home/data/models/notification_model.dart';
import 'package:doctor_appointment/core/services/service_locator.dart';
import 'package:doctor_appointment/features/home/logic/notification_cubit.dart';
import 'package:doctor_appointment/features/home/logic/notification_state.dart';
import '../widgets/notification_tile.dart';
import '../widgets/shared_app_bar.dart';
import 'package:doctor_appointment/core/utils/app_dimensions.dart';
import 'package:doctor_appointment/l10n/app_localizations.dart';

import 'package:doctor_appointment/core/theme/app_theme_extension.dart';

class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return BlocProvider(
      create: (context) => getIt<NotificationCubit>()..fetchNotifications(),
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: _buildAppBar(context),
        body: _buildBody(context),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SharedAppBar(
      title: AppLocalizations.of(context)!.notificationsTitle,
      actions: [
        BlocBuilder<NotificationCubit, NotificationState>(
          builder: (context, state) {
            if (state is NotificationSuccess && state.unreadCount > 0) {
              return Padding(
                padding: EdgeInsets.only(right: 16.w),
                child: Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text(
                      '${state.unreadCount} NEW',
                      style: TextStyle(
                        color: colorScheme.onPrimary,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return BlocBuilder<NotificationCubit, NotificationState>(
      builder: (context, state) {
        if (state is NotificationLoading) {
          return Skeletonizer(
            enabled: true,
            child: ListView.builder(
              padding: EdgeInsets.all(AppSpacing.lg),
              itemCount: 8,
              itemBuilder: (context, index) {
                return NotificationTile(
                  notification: NotificationModel(
                    id: index,
                    title: 'Notification Title Loading...',
                    message:
                        'Notification body content loading placeholder text.',
                    createdAt: DateTime.now(),
                    isRead: false,
                    type: null,
                  ),
                );
              },
            ),
          );
        } else if (state is NotificationError) {
          return Center(child: Text(state.message));
        } else if (state is NotificationSuccess) {
          final notifications = state.notifications;
          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Iconsax.notification_bing,
                    size: 80.sp,
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.2),
                  ),
                  SizedBox(height: AppSpacing.md),
                  Text(
                    AppLocalizations.of(context)!.noNotificationsYet,
                    style: context.headingSmall.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: AppSpacing.sm),
                  Text(
                    AppLocalizations.of(context)!.noNotificationsSubtitle,
                    style: context.bodySmall.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          // Simple grouping for UI (can be enhanced to group by Today/Yesterday)
          return RefreshIndicator(
            onRefresh: () =>
                context.read<NotificationCubit>().fetchNotifications(),
            child: ListView.builder(
              padding: EdgeInsets.all(AppSpacing.lg),
              itemCount: notifications.length + 1, // +1 for the Mark All label
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: AppSpacing.md),
                    child: _SectionLabel(
                      label: AppLocalizations.of(context)!.allNotifications,
                      onMarkAll: () =>
                          context.read<NotificationCubit>().markAllAsRead(),
                    ),
                  );
                }
                final notification = notifications[index - 1];
                return NotificationTile(
                  notification: notification,
                  onSeen: () => context.read<NotificationCubit>().markAsRead(
                    notification.id,
                  ),
                );
              },
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, this.onMarkAll});
  final String label;
  final VoidCallback? onMarkAll;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: context.headingSmall.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        if (onMarkAll != null)
          GestureDetector(
            onTap: onMarkAll,
            child: Text(
              AppLocalizations.of(context)!.markAllAsRead,
              style: context.labelLarge.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }
}

