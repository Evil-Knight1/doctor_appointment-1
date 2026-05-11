import 'dart:ui';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:doctor_appointment/core/services/shared_preferences_helper.dart';

class LocaleCubit extends Cubit<Locale> {
  LocaleCubit() : super(_getInitialLocale());

  static Locale _getInitialLocale() {
    final savedLanguageCode = SharedPreferencesHelper.getString(
      'language_code',
    );
    if (savedLanguageCode != null) {
      return Locale(savedLanguageCode);
    }

    final systemLocale = PlatformDispatcher.instance.locale;
    final systemLanguageCode = systemLocale.languageCode;

    // Check if system language is supported, else default to 'en'
    if (['en', 'ar'].contains(systemLanguageCode)) {
      return Locale(systemLanguageCode);
    }

    return const Locale('en');
  }

  void changeLocale(String languageCode) {
    SharedPreferencesHelper.setData('language_code', languageCode);
    emit(Locale(languageCode));
  }
}
