import 'package:doctor_appointment/core/utils/app_styles.dart';
import 'package:doctor_appointment/core/utils/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class MedicalRecordsView extends StatelessWidget {
  const MedicalRecordsView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: colorScheme.onSurface,
            size: 20.sp,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Medical Records',
          style: AppStyles.styleSemiBold22.copyWith(
            fontSize: 18.sp,
            color: colorScheme.onSurface,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRouter.kCreateRecordView),
        backgroundColor: colorScheme.primary,
        child: Icon(Icons.add_rounded, color: colorScheme.onPrimary),
      ),
      body: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        itemCount: 4,
        separatorBuilder: (context, index) => SizedBox(height: 12.h),
        itemBuilder: (context, index) {
          return _buildRecordCard(context, index);
        },
      ),
    );
  }

  Widget _buildRecordCard(BuildContext context, int index) {
    final colorScheme = Theme.of(context).colorScheme;
    final titles = [
      'Blood Test Results',
      'Dental X-Ray',
      'General Checkup',
      'Eye Vision Prescription'
    ];
    final dates = ['12 Oct, 2023', '05 Sep, 2023', '14 Jul, 2023', '22 Jan, 2023'];
    final icons = [
      Icons.bloodtype_outlined,
      Icons.masks_outlined,
      Icons.health_and_safety_outlined,
      Icons.remove_red_eye_outlined
    ];
    final docs = ['Dr. Sarah', 'Dr. Ayesha Rahman', 'Dr. Noble Thorme', 'Dr. Sarah'];
    
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Theme.of(context).dividerColor),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              icons[index % icons.length],
              color: colorScheme.primary,
              size: 24.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titles[index % titles.length],
                  style: AppStyles.styleSemiBold16.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Added by ${docs[index % docs.length]}',
                  style: AppStyles.styleMedium14.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  dates[index % dates.length],
                  style: AppStyles.styleRegular12.copyWith(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: colorScheme.onSurfaceVariant,
            size: 24.sp,
          ),
        ],
      ),
    );
  }
}
