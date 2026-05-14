import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:doctor_appointment/core/utils/app_dimensions.dart';
import 'package:doctor_appointment/core/utils/routes.dart';
import 'package:doctor_appointment/core/utils/app_styles.dart';
import '../widgets/doctor_bottom_card.dart';
import '../widgets/shared_app_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:doctor_appointment/features/doctors/logic/doctors_cubit.dart';
import 'package:doctor_appointment/features/doctors/logic/doctors_state.dart';
import 'package:doctor_appointment/features/home/presentation/widgets/recommended_doctors_list.dart';
import 'package:doctor_appointment/core/theme/app_theme_extension.dart';

class FindNearbyView extends StatelessWidget {
  const FindNearbyView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: SharedAppBar(
        title: 'Find Nearby',
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: Icon(Icons.tune_rounded,
                color: colorScheme.onSurfaceVariant, size: 24.sp),
          ),
        ],
      ),
      body: Stack(
        children: [
          const _MapBackground(),
          const _SearchOverlay(),
          BlocBuilder<DoctorsCubit, DoctorsState>(
            builder: (context, state) {
              if (state is DoctorsSuccess && state.page.items.isNotEmpty) {
                final doctor = state.page.items.first.toHomeModel();
                return Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: DoctorBottomCard(
                    doctor: doctor,
                    onTap: () => context.pushNamed(
                      Routes.doctorDetailsView,
                      extra: doctor,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}

class _MapBackground extends StatelessWidget {
  const _MapBackground();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final customColors = context.customColors;
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: colorScheme.surfaceContainer,
      child: CustomPaint(
        painter: _MapPainter(
          roadColor: colorScheme.surface,
          roadBorderColor: colorScheme.outlineVariant,
          blockColor: colorScheme.surfaceContainerHighest,
          primaryColor: colorScheme.primary,
          successColor: customColors.success ?? Colors.green,
        ),
      ),
    );
  }
}

class _MapPainter extends CustomPainter {
  final Color roadColor;
  final Color roadBorderColor;
  final Color blockColor;
  final Color primaryColor;
  final Color successColor;

  _MapPainter({
    required this.roadColor,
    required this.roadBorderColor,
    required this.blockColor,
    required this.primaryColor,
    required this.successColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = roadColor
      ..strokeWidth = 14.w
      ..strokeCap = StrokeCap.round;
    final roadBorderPaint = Paint()
      ..color = roadBorderColor
      ..strokeWidth = 16.w
      ..strokeCap = StrokeCap.round;
    final blockPaint = Paint()..color = blockColor;

    for (var i = 0; i < 6; i++) {
      for (var j = 0; j < 8; j++) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(i * 90.w + 20.w, j * 100.h + 20.h, 60.w, 65.h),
            Radius.circular(8.r),
          ),
          blockPaint,
        );
      }
    }

    for (var i = 0; i <= 6; i++) {
      canvas.drawLine(
        Offset(i * 90.0.w, 0),
        Offset(i * 90.0.w, size.height),
        roadBorderPaint,
      );
      canvas.drawLine(
        Offset(i * 90.0.w, 0),
        Offset(i * 90.0.w, size.height),
        roadPaint,
      );
    }
    for (var j = 0; j <= 8; j++) {
      canvas.drawLine(
        Offset(0, j * 100.0.h),
        Offset(size.width, j * 100.0.h),
        roadBorderPaint,
      );
      canvas.drawLine(
        Offset(0, j * 100.0.h),
        Offset(size.width, j * 100.0.h),
        roadPaint,
      );
    }

    _drawPin(canvas, Offset(size.width * 0.3, size.height * 0.25), primaryColor);
    _drawPin(canvas, Offset(size.width * 0.65, size.height * 0.35), primaryColor);
    _drawPin(canvas, Offset(size.width * 0.5, size.height * 0.55), successColor);

    final userPaint = Paint()..color = primaryColor;
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.55),
      10.r,
      Paint()..color = primaryColor.withValues(alpha: 0.2),
    );
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.55), 6.r, userPaint);
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.55),
      3.r,
      Paint()..color = roadColor,
    );
  }

  void _drawPin(Canvas canvas, Offset center, Color color) {
    final paint = Paint()..color = color;
    canvas.drawCircle(center, 22.r, Paint()..color = color.withValues(alpha: 0.15));
    canvas.drawCircle(center, 16.r, paint);
    canvas.drawCircle(center, 8.r, Paint()..color = roadColor);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SearchOverlay extends StatelessWidget {
  const _SearchOverlay();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Positioned(
      top: AppSpacing.lg,
      left: AppSpacing.lg,
      right: AppSpacing.lg,
      child: Container(
        height: 48.h,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 12.r,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
        child: Row(
          children: [
            SizedBox(width: 14.w),
            Icon(Icons.search_rounded, color: colorScheme.onSurfaceVariant, size: 20.sp),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                'Search here...',
                style: context.bodyMedium.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.all(6.r),
              padding: EdgeInsets.all(6.r),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(Icons.tune_rounded, color: colorScheme.primary, size: 16.sp),
            ),
          ],
        ),
      ),
    );
  }
}
