import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:doctor_appointment/features/home/data/models/home_doctor_model.dart';

class SharedPreferencesHelper {
  static late SharedPreferences _prefs;

  static final ValueNotifier<int> favoritesVersion = ValueNotifier(0);

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Onboarding
  static Future<bool> saveHasSeenOnboarding(bool value) async {
    return await _prefs.setBool('has_seen_onboarding', value);
  }

  static bool getHasSeenOnboarding() {
    return _prefs.getBool('has_seen_onboarding') ?? false;
  }

  // Token
  static Future<bool> saveToken(String token) async {
    return await _prefs.setString('token', token);
  }

  static String? getToken() {
    return _prefs.getString('token');
  }

  static Future<bool> removeToken() async {
    return await _prefs.remove('token');
  }

  // User Data JSON String
  static Future<bool> saveUserData(String userDataJson) async {
    return await _prefs.setString('user_data', userDataJson);
  }

  static String? getUserData() {
    return _prefs.getString('user_data');
  }

  static Future<bool> removeUserData() async {
    return await _prefs.remove('user_data');
  }

  // Favorites (saving list of Doctor JSONs)
  static Future<bool> toggleFavoriteDoctor(HomeDoctorModel doctor) async {
    final docs = getFavoriteDoctors();
    final isFav = docs.any((d) => d.name == doctor.name);

    if (isFav) {
      docs.removeWhere((d) => d.name == doctor.name);
    } else {
      docs.add(doctor);
    }

    final jsonList = docs.map((d) => jsonEncode(d.toJson())).toList();
    final result = await _prefs.setStringList('favorite_doctors', jsonList);
    favoritesVersion.value++;
    return result;
  }

  static List<HomeDoctorModel> getFavoriteDoctors() {
    final jsonList = _prefs.getStringList('favorite_doctors');
    if (jsonList == null) return [];

    return jsonList
        .map((str) => HomeDoctorModel.fromJson(jsonDecode(str)))
        .toList();
  }

  static bool isDoctorFavorite(String name) {
    return getFavoriteDoctors().any((d) => d.name == name);
  }

  // Theme
  static Future<bool> saveThemeMode(String themeMode) async {
    return await _prefs.setString('theme_mode', themeMode);
  }

  static String getThemeMode() {
    return _prefs.getString('theme_mode') ?? 'system';
  }

  // User Profile Caching
  static Future<bool> saveProfileInfo(String name, String? image) async {
    final nameResult = await _prefs.setString('user_name', name);
    if (image != null) {
      await _prefs.setString('user_image', image);
    } else {
      await _prefs.remove('user_image');
    }
    return nameResult;
  }

  static String? getProfileName() {
    return _prefs.getString('user_name');
  }

  static String? getProfileImage() {
    return _prefs.getString('user_image');
  }

  static Future<void> clearAll() async {
    await _prefs.clear();
  }

  // Generic methods
  static String? getString(String key) {
    return _prefs.getString(key);
  }

  static Future<bool> setData(String key, dynamic value) async {
    if (value is String) return await _prefs.setString(key, value);
    if (value is int) return await _prefs.setInt(key, value);
    if (value is bool) return await _prefs.setBool(key, value);
    if (value is double) return await _prefs.setDouble(key, value);
    if (value is List<String>) return await _prefs.setStringList(key, value);
    return false;
  }
}
