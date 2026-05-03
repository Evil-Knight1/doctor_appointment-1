import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:doctor_appointment/core/utils/app_dimensions.dart';
import 'package:doctor_appointment/features/home/data/models/home_model.dart';
import 'package:doctor_appointment/core/utils/app_colors.dart';
import 'package:doctor_appointment/core/utils/app_styles.dart';

class NotificationTile extends StatelessWidget {
  const NotificationTile({super.key, required this.item});
  final NotificationItemModel item;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.md),
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: item.isRead ? AppColors.surface : AppColors.primaryLight,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: item.isRead
            ? null
            : Border.all(color: AppColors.primary.withValues(alpha: 0.15), width: 1.w),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow.withValues(alpha: 0.07),
            blurRadius: 10.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44.w,
            height: 44.h,
            decoration: BoxDecoration(
              color: item.iconBg,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(item.icon, color: item.iconColor, size: 22.sp),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(item.title, style: AppTextStyles.headingSmall),
                    Text(item.timeAgo, style: AppTextStyles.bodySmall),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  item.message,
                  style: AppTextStyles.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (!item.isRead) ...[
            SizedBox(width: 8.w),
            Container(
              width: 8.w,
              height: 8.h,
              margin: EdgeInsets.only(top: 4.h),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
