import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:doctor_appointment/core/utils/app_dimensions.dart';
import 'package:doctor_appointment/features/home/data/models/home_model.dart';
import 'package:doctor_appointment/core/utils/routes.dart';
import 'package:doctor_appointment/core/utils/app_colors.dart';
import 'package:doctor_appointment/core/utils/app_styles.dart';
import '../widgets/doctor_bottom_card.dart';
import '../widgets/shared_app_bar.dart';

class FindNearbyView extends StatelessWidget {
  const FindNearbyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: SharedAppBar(
        title: 'Find Nearby',
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: Icon(Icons.tune_rounded,
                color: AppColors.textSecondary, size: 24.sp),
          ),
        ],
      ),
      body: Stack(
        children: [
          const _MapBackground(),
          const _SearchOverlay(),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: DoctorBottomCard(
              doctor: HomeStaticData.recommendedDoctors.first,
              onTap: () => context.pushNamed(
                Routes.doctorDetailsView,
                extra: HomeStaticData.recommendedDoctors.first,
              ),
            ),
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
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFFE8F0FE),
      child: CustomPaint(painter: _MapPainter()),
    );
  }
}

class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 14.w
      ..strokeCap = StrokeCap.round;
    final roadBorderPaint = Paint()
      ..color = const Color(0xFFD1D5DB)
      ..strokeWidth = 16.w
      ..strokeCap = StrokeCap.round;
    final blockPaint = Paint()..color = const Color(0xFFDDE6FB);

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

    _drawPin(canvas, Offset(size.width * 0.3, size.height * 0.25), AppColors.primary);
    _drawPin(canvas, Offset(size.width * 0.65, size.height * 0.35), AppColors.primary);
    _drawPin(canvas, Offset(size.width * 0.5, size.height * 0.55), const Color(0xFF059669));

    final userPaint = Paint()..color = AppColors.primary;
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.55),
      10.r,
      Paint()..color = AppColors.primary.withValues(alpha: 0.2),
    );
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.55), 6.r, userPaint);
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.55),
      3.r,
      Paint()..color = Colors.white,
    );
  }

  void _drawPin(Canvas canvas, Offset center, Color color) {
    final paint = Paint()..color = color;
    canvas.drawCircle(center, 22.r, Paint()..color = color.withValues(alpha: 0.15));
    canvas.drawCircle(center, 16.r, paint);
    canvas.drawCircle(center, 8.r, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SearchOverlay extends StatelessWidget {
  const _SearchOverlay();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: AppSpacing.lg,
      left: AppSpacing.lg,
      right: AppSpacing.lg,
      child: Container(
        height: 48.h,
        decoration: BoxDecoration(
          color: AppColors.surface,
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
            Icon(Icons.search_rounded, color: AppColors.textHint, size: 20.sp),
            SizedBox(width: 8.w),
            Expanded(
              child: Text('Search here...', style: AppTextStyles.bodyMedium),
            ),
            Container(
              margin: EdgeInsets.all(6.r),
              padding: EdgeInsets.all(6.r),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(Icons.tune_rounded, color: AppColors.primary, size: 16.sp),
            ),
          ],
        ),
      ),
    );
  }
}
