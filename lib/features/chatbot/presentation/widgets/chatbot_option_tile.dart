import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChatbotOptionTile extends StatelessWidget {
  const ChatbotOptionTile({
    super.key,
    required this.text,
    required this.selected,
    required this.onTap,
    required this.indicator,
    this.enabled = true,
  });

  final String text;
  final bool selected;
  final VoidCallback onTap;
  final Widget indicator;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: InkWell(
        borderRadius: BorderRadius.circular(18.r),
        onTap: enabled ? onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
          decoration: BoxDecoration(
            color: selected
                ? theme.colorScheme.primary.withValues(alpha: .08)
                : theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(
              color: selected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline.withValues(alpha: .15),
              width: 1.4,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  text,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              indicator,
            ],
          ),
        ),
      ),
    );
  }
}
