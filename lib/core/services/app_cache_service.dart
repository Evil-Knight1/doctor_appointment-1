import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:doctor_appointment/features/appointment/data/models/appointment_model.dart';
import 'package:doctor_appointment/features/profile/data/models/patient_profile_model.dart';

class AppCacheService {
  static const String profileBoxName = 'app_profile';
  static const String appointmentsBoxName = 'app_appointments';
  
  static const String _profileKey = 'patient_profile';
  static const String _appointmentsKey = 'my_appointments';

  final Box<String> _profileBox;
  final Box<String> _appointmentsBox;

  AppCacheService(this._profileBox, this._appointmentsBox);

  static Future<void> openBoxes() async {
    await Hive.openBox<String>(profileBoxName);
    await Hive.openBox<String>(appointmentsBoxName);
  }

  // ── Profile ───────────────────────────────────────────────────────────────

  PatientProfileModel? getCachedProfile() {
    final raw = _profileBox.get(_profileKey);
    if (raw == null) return null;
    try {
      return PatientProfileModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> cacheProfile(PatientProfileModel profile) async {
    await _profileBox.put(_profileKey, jsonEncode(profile.toJson()));
  }

  // ── Appointments ──────────────────────────────────────────────────────────

  List<AppointmentModel> getCachedAppointments() {
    final raw = _appointmentsBox.get(_appointmentsKey);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => AppointmentModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> cacheAppointments(List<AppointmentModel> appointments) async {
    final jsonList = appointments.map((a) => a.toJson()).toList();
    await _appointmentsBox.put(_appointmentsKey, jsonEncode(jsonList));
  }

  // ── Clear All ─────────────────────────────────────────────────────────────

  Future<void> clearAll() async {
    await _profileBox.clear();
    await _appointmentsBox.clear();
  }
}
