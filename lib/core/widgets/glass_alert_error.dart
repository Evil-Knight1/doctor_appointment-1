import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GlassAlert {
  static void show(
    BuildContext context, {
    required String title,
    required String message,
    IconData icon = Icons.info_outline_rounded,
    Color iconColor = Colors.orange,
    Duration duration = const Duration(seconds: 4),
  }) {
    final overlay = Overlay.of(context);

    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) {
        return _GlassAlertWidget(
          title: title,
          message: message,
          icon: icon,
          iconColor: iconColor,
        );
      },
    );

    overlay.insert(entry);

    Future.delayed(duration, () {
      entry.remove();
    });
  }
}

class _GlassAlertWidget extends StatefulWidget {
  const _GlassAlertWidget({
    required this.title,
    required this.message,
    required this.icon,
    required this.iconColor,
  });

  final String title;
  final String message;
  final IconData icon;
  final Color iconColor;

  @override
  State<_GlassAlertWidget> createState() => _GlassAlertWidgetState();
}

class _GlassAlertWidgetState extends State<_GlassAlertWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<Offset> _slideAnimation;

  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 60.h,
      left: 16.w,
      right: 16.w,

      child: Material(
        color: Colors.transparent,

        child: FadeTransition(
          opacity: _fadeAnimation,

          child: SlideTransition(
            position: _slideAnimation,

            child: ClipRRect(
              borderRadius: BorderRadius.circular(24.r),

              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),

                child: Container(
                  padding: EdgeInsets.all(18.w),

                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24.r),

                    color: Colors.white.withValues(alpha: 0.08),

                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.12),
                    ),

                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),

                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Container(
                        width: 46.w,
                        height: 46.w,

                        decoration: BoxDecoration(
                          shape: BoxShape.circle,

                          color: widget.iconColor.withValues(alpha: .15),
                        ),

                        child: Icon(
                          widget.icon,
                          color: widget.iconColor,
                          size: 24.sp,
                        ),
                      ),

                      SizedBox(width: 14.w),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            Text(
                              widget.title,

                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 15.sp,
                              ),
                            ),

                            SizedBox(height: 4.h),

                            Text(
                              widget.message,

                              style: TextStyle(
                                color: Colors.white.withValues(alpha: .75),
                                fontSize: 13.sp,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
