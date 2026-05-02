import 'package:doctor_appointment/core/services/shared_preferences_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(_getInitialTheme());

  static ThemeMode _getInitialTheme() {
    final mode = SharedPreferencesHelper.getThemeMode();
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  void toggleTheme(bool isDark) {
    final newMode = isDark ? ThemeMode.dark : ThemeMode.light;
    SharedPreferencesHelper.saveThemeMode(isDark ? 'dark' : 'light');
    emit(newMode);
  }

  void setSystemTheme() {
    SharedPreferencesHelper.saveThemeMode('system');
    emit(ThemeMode.system);
  }
}
