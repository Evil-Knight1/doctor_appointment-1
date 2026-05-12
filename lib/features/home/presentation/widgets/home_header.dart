import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:doctor_appointment/core/utils/app_dimensions.dart';
import 'package:doctor_appointment/core/utils/app_styles.dart';
import 'package:doctor_appointment/core/utils/app_colors.dart';
import 'package:doctor_appointment/core/utils/image_url_helper.dart';

import 'package:doctor_appointment/l10n/app_localizations.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key, required this.userName, this.userImageUrl});

  final String userName;
  final String? userImageUrl;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _GreetingText(userName: userName, userImageUrl: userImageUrl),
          SizedBox(height: AppSpacing.lg),
          const _HeroBanner(),
        ],
      ),
    );
  }
}

class _GreetingText extends StatelessWidget {
  const _GreetingText({required this.userName, this.userImageUrl});

  final String userName;
  final String? userImageUrl;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${l10n.hi}, $userName! 👋',
              style: AppTextStyles.displayMedium,
            ),
            SizedBox(height: 2.h),
            Text(l10n.howAreYou, style: AppTextStyles.bodyMedium),
          ],
        ),
        _AvatarButton(userImageUrl: userImageUrl),
      ],
    );
  }
}

class _AvatarButton extends StatelessWidget {
  const _AvatarButton({this.userImageUrl});

  final String? userImageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48.r,
      height: 48.r,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 2.w,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipOval(
        child: userImageUrl != null
            ? CachedNetworkImage(
                imageUrl: ImageUrlHelper.getFullUrl(userImageUrl),
                                  httpHeaders: ImageUrlHelper.getImageHeaders(),
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: AppColors.primaryLight,
                  child: Center(
                    child: SizedBox(
                      width: 16.w,
                      height: 16.h,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => _buildPlaceholder(),
              )
            : _buildPlaceholder(),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Icon(Icons.person_rounded, color: Colors.white, size: 24.sp),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 190.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        gradient: const LinearGradient(
          colors: [AppColors.headerGradientStart, AppColors.headerGradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 20.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Stack(children: [_BannerDecoration(), const _BannerContent()]),
    );
  }
}

class _BannerDecoration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Stack(
          children: [
            Positioned(
              right: -20.w,
              top: -20.h,
              child: Container(
                width: 130.w,
                height: 130.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.07),
                ),
              ),
            ),
            Positioned(
              right: 50.w,
              bottom: -30.h,
              child: Container(
                width: 90.w,
                height: 90.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BannerContent extends StatelessWidget {
  const _BannerContent();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.lg,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: const _BannerText()),
          SizedBox(width: AppSpacing.md),
          const _BannerImage(),
        ],
      ),
    );
  }
}

class _BannerText extends StatelessWidget {
  const _BannerText();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(l10n.bookNearestDoctor, style: AppTextStyles.greetingTitle),
        SizedBox(height: AppSpacing.md),
        const _FindNearbyButton(),
      ],
    );
  }
}

class _FindNearbyButton extends StatelessWidget {
  const _FindNearbyButton();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.full),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Text(
        l10n.findNearby,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class _BannerImage extends StatelessWidget {
  const _BannerImage();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90.w,
      height: 100.h,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Center(
        child: Icon(
          Icons.medical_services_rounded,
          size: 52.sp,
          color: Colors.white,
        ),
      ),
    );
  }
}
