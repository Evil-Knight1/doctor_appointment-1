import 'package:doctor_appointment/core/utils/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ConsultationFeesWidget extends StatelessWidget {
  final double fee;
  const ConsultationFeesWidget({super.key, required this.fee});

  List<Map<String, dynamic>> get _fees => [
        {'label': 'Online Call', 'amount': '\$${fee.toStringAsFixed(0)}', 'icon': Icons.call_outlined},
        {'label': 'Home Visit', 'amount': '\$${(fee * 1.5).toStringAsFixed(0)}', 'icon': Icons.home_outlined},
        {'label': 'Video Call', 'amount': '\$${(fee * 1.2).toStringAsFixed(0)}', 'icon': Icons.videocam_outlined},
      ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: List.generate(_fees.length, (i) {
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: i < 2 ? 10.w : 0),
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Column(
              children: [
                Icon(
                  _fees[i]['icon'] as IconData,
                  color: colorScheme.primary,
                  size: 20.sp,
                ),
                SizedBox(height: 4.h),
                Text(
                  _fees[i]['amount'] as String,
                  style: AppStyles.styleSemiBold22.copyWith(
                    fontSize: 14.sp,
                    color: colorScheme.primary,
                  ),
                ),
                Text(
                  _fees[i]['label'] as String,
                  style: AppStyles.styleRegular12.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 10.sp,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

