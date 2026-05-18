import 'package:doctor_appointment/core/utils/go_router.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:doctor_appointment/core/utils/routes.dart';

import 'package:doctor_appointment/features/home/logic/notification_cubit.dart';
import 'package:doctor_appointment/features/home/logic/notification_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:doctor_appointment/core/services/service_locator.dart';

import 'package:doctor_appointment/features/profile/logic/profile_cubit.dart';
import 'package:doctor_appointment/features/profile/logic/profile_state.dart';
import 'package:doctor_appointment/core/services/shared_preferences_helper.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:doctor_appointment/core/utils/image_url_helper.dart';
import 'package:doctor_appointment/core/theme/app_theme_extension.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Size get preferredSize => Size.fromHeight(70.h);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      toolbarHeight: 70.h,
      titleSpacing: 20.w,
      title: const _UserInfoRow(),
      actions: [
        const _NotificationButton(),
        SizedBox(width: 16.w),
      ],
    );
  }
}

class _UserInfoRow extends StatelessWidget {
  const _UserInfoRow();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        String name = SharedPreferencesHelper.getProfileName() ?? 'User';
        String? image = SharedPreferencesHelper.getProfileImage();

        if (state is ProfileSuccess) {
          name = state.profile.fullName;
          image = state.profile.profilePicture;
        }

        return Row(
          children: [
            GestureDetector(
              onTap: () => context.push(AppRouter.kProfileView),
              child: Container(
                width: 45.r,
                height: 45.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: colorScheme.primaryContainer, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.shadow.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: image != null
                      ? CachedNetworkImage(
                          imageUrl: ImageUrlHelper.getFullUrl(image),
                          httpHeaders: ImageUrlHelper.getImageHeaders(),
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Skeletonizer(
                            enabled: true,
                            child: Container(
                              width: 45.r,
                              height: 45.r,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: colorScheme.primaryContainer,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) =>
                              _buildDefaultAvatar(context),
                        )
                      : _buildDefaultAvatar(context),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hi, $name 👋',
                  style: context.styleSemiBold22.copyWith(
                    fontSize: 18.sp,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  'Find your best doctor',
                  style: context.styleRegular12.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildDefaultAvatar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      color: colorScheme.primaryContainer,
      child: Icon(Icons.person_rounded, color: colorScheme.primary, size: 28.sp),
    );
  }
}

class _NotificationButton extends StatelessWidget {
  const _NotificationButton();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocProvider(
      create: (context) => getIt<NotificationCubit>()..fetchUnreadCount(),
      child: BlocBuilder<NotificationCubit, NotificationState>(
        builder: (context, state) {
          final unreadCount = state is NotificationSuccess
              ? state.unreadCount
              : 0;
          return Stack(
            clipBehavior: Clip.none,
            children: [
              GestureDetector(
                onTap: () =>
                    context.pushNamed(Routes.notificationView).then((_) {
                      if (context.mounted) {
                        context.read<NotificationCubit>().fetchUnreadCount();
                      }
                    }),
                child: Container(
                  width: 40.w,
                  height: 40.h,
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.shadow.withValues(alpha: 0.08),
                        blurRadius: 8.r,
                        offset: Offset(0, 2.h),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.notifications_outlined,
                    size: 20.sp,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              if (unreadCount > 0)
                Positioned(
                  top: -4.h,
                  right: -4.w,
                  child: Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: colorScheme.error,
                      shape: BoxShape.circle,
                    ),
                    constraints: BoxConstraints(
                      minWidth: 16.w,
                      minHeight: 16.h,
                    ),
                    child: Text(
                      unreadCount > 9 ? '9+' : '$unreadCount',
                      style: TextStyle(
                        color: colorScheme.onError,
                        fontSize: 8.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
