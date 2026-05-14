import 'package:doctor_appointment/core/theme/app_theme_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ConsultationFeesWidget extends StatelessWidget {
  final double fee;
  final String selectedType;
  const ConsultationFeesWidget({
    super.key,
    required this.fee,
    required this.selectedType,
  });

  List<Map<String, dynamic>> get _fees => [
    {
      'label': 'Online',
      'amount': '${fee.toStringAsFixed(0)} EGP',
      'icon': Icons.laptop_mac_outlined,
    },
    {
      'label': 'Home visit',
      'amount': '${(fee * 1.5).toStringAsFixed(0)} EGP',
      'icon': Icons.home_outlined,
    },
    {
      'label': 'Clinic',
      'amount': '${fee.toStringAsFixed(0)} EGP',
      'icon': Icons.local_hospital_outlined,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: List.generate(_fees.length, (i) {
        final isSelected = selectedType == _fees[i]['label'];
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: i < 2 ? 10.w : 0),
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: isSelected
                  ? colorScheme.primaryContainer.withValues(alpha: 0.1)
                  : colorScheme.surface,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: isSelected ? colorScheme.primary : colorScheme.outlineVariant,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  _fees[i]['icon'] as IconData,
                  color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
                  size: 20.sp,
                ),
                SizedBox(height: 4.h),
                Text(
                  _fees[i]['amount'] as String,
                  style: context.styleSemiBold22.copyWith(
                    fontSize: 14.sp,
                    color: isSelected ? colorScheme.primary : colorScheme.onSurface,
                  ),
                ),
                Text(
                  _fees[i]['label'] as String,
                  style: context.styleRegular12.copyWith(
                    color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
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
