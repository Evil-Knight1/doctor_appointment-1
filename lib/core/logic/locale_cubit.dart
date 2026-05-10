import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:doctor_appointment/core/services/shared_preferences_helper.dart';

class LocaleCubit extends Cubit<Locale> {
  LocaleCubit() : super(_getInitialLocale());

  static Locale _getInitialLocale() {
    final languageCode = SharedPreferencesHelper.getString('language_code') ?? 'en';
    return Locale(languageCode);
  }

  void changeLocale(String languageCode) {
    SharedPreferencesHelper.setData('language_code', languageCode);
    emit(Locale(languageCode));
  }
}
