import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'chatbot_option_tile.dart';
import 'chatbot_submit_button.dart';

class ChatbotRadioSelector extends StatelessWidget {
  const ChatbotRadioSelector({
    super.key,
    required this.options,
    required this.selectedValue,
    required this.onChanged,
    required this.onSubmit,
    required this.isLoading,
    required this.allowOther,
    this.onOtherTap,
  });

  final List<String> options;
  final String? selectedValue;
  final ValueChanged<String> onChanged;
  final VoidCallback onSubmit;
  final bool isLoading;

  final bool allowOther;
  final VoidCallback? onOtherTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Choose one option",
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),

          SizedBox(height: 16.h),

          ...options.map((option) {
            final isSelected = selectedValue == option;

            return ChatbotOptionTile(
              text: option,
              selected: isSelected,
              enabled: !isLoading,
              onTap: () => onChanged(option),

              indicator: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 22.w,
                height: 22.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outline,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: isSelected ? 10.w : 0,
                    height: isSelected ? 10.w : 0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
            );
          }),

          if (allowOther) ...[
            SizedBox(height: 4.h),

            OutlinedButton(
              onPressed: isLoading ? null : onOtherTap,
              child: const Text("Other"),
            ),
          ],

          SizedBox(height: 20.h),

          ChatbotSubmitButton(
            enabled: !isLoading && selectedValue != null,
            onPressed: onSubmit,
          ),
        ],
      ),
    );
  }
}
