import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Spacing tokens used for padding, margin, and gaps throughout the app.
class AppSpacing {
  AppSpacing._();

  static double get xs => 4.w;
  static double get sm => 8.w;
  static double get md => 12.w;
  static double get lg => 16.w;
  static double get xl => 20.w;
  static double get xxl => 24.w;
  static double get xxxl => 32.w;
}

/// Border-radius tokens used across cards, buttons, and containers.
class AppRadius {
  AppRadius._();

  static double get xs => 4.r;
  static double get sm => 8.r;
  static double get md => 12.r;
  static double get lg => 16.r;
  static double get xl => 20.r;
  static double get xxl => 28.r;
  static double get full => 999.r;
}
