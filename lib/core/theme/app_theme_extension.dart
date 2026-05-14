import 'package:flutter/material.dart';

class AppCustomColors extends ThemeExtension<AppCustomColors> {
  final Color? success;
  final Color? warning;
  final Color? appointmentPending;
  final Color? doctorOnline;
  final Color? chatBubbleMine;
  final Color? chatBubbleOthers;
  final Color? chatBubbleMineGradientStart;
  final Color? chatBubbleMineGradientEnd;
  final Color? rating;
  final Color? error;
  final Color? offline;

  const AppCustomColors({
    required this.success,
    required this.warning,
    required this.appointmentPending,
    required this.doctorOnline,
    required this.chatBubbleMine,
    required this.chatBubbleOthers,
    required this.chatBubbleMineGradientStart,
    required this.chatBubbleMineGradientEnd,
    required this.rating,
    required this.error,
    this.offline,
  });

  @override
  AppCustomColors copyWith({
    Color? success,
    Color? warning,
    Color? appointmentPending,
    Color? doctorOnline,
    Color? chatBubbleMine,
    Color? chatBubbleOthers,
    Color? chatBubbleMineGradientStart,
    Color? chatBubbleMineGradientEnd,
    Color? rating,
    Color? error,
    Color? offline,
  }) {
    return AppCustomColors(
      success: success ?? this.success,
      warning: warning ?? this.warning,
      appointmentPending: appointmentPending ?? this.appointmentPending,
      doctorOnline: doctorOnline ?? this.doctorOnline,
      chatBubbleMine: chatBubbleMine ?? this.chatBubbleMine,
      chatBubbleOthers: chatBubbleOthers ?? this.chatBubbleOthers,
      chatBubbleMineGradientStart:
          chatBubbleMineGradientStart ?? this.chatBubbleMineGradientStart,
      chatBubbleMineGradientEnd:
          chatBubbleMineGradientEnd ?? this.chatBubbleMineGradientEnd,
      rating: rating ?? this.rating,
      error: error ?? this.error,
      offline: offline ?? this.offline,
    );
  }

  @override
  AppCustomColors lerp(ThemeExtension<AppCustomColors>? other, double t) {
    if (other is! AppCustomColors) return this;
    return AppCustomColors(
      success: Color.lerp(success, other.success, t),
      warning: Color.lerp(warning, other.warning, t),
      appointmentPending:
          Color.lerp(appointmentPending, other.appointmentPending, t),
      doctorOnline: Color.lerp(doctorOnline, other.doctorOnline, t),
      chatBubbleMine: Color.lerp(chatBubbleMine, other.chatBubbleMine, t),
      chatBubbleOthers: Color.lerp(chatBubbleOthers, other.chatBubbleOthers, t),
      chatBubbleMineGradientStart: Color.lerp(
          chatBubbleMineGradientStart, other.chatBubbleMineGradientStart, t),
      chatBubbleMineGradientEnd: Color.lerp(
          chatBubbleMineGradientEnd, other.chatBubbleMineGradientEnd, t),
      rating: Color.lerp(rating, other.rating, t),
      error: Color.lerp(error, other.error, t),
      offline: Color.lerp(offline, other.offline, t),
    );
  }
}

extension CustomTheme on BuildContext {
  AppCustomColors get customColors => Theme.of(this).extension<AppCustomColors>()!;
}
