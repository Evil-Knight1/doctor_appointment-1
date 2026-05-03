import 'package:flutter/material.dart';

// ─── Doctor Model ───────────────────────────────────────────────────────────

class DoctorModel {
  const DoctorModel({
    required this.id,
    required this.name,
    required this.speciality,
    required this.hospital,
    required this.rating,
    required this.reviewCount,
    required this.avatarAsset,
    this.isAvailable = true,
  });

  final String id;
  final String name;
  final String speciality;
  final String hospital;
  final double rating;
  final int reviewCount;
  final String avatarAsset;
  final bool isAvailable;
}

// ─── Speciality Model ────────────────────────────────────────────────────────

class SpecialityModel {
  const SpecialityModel({
    required this.name,
    required this.icon,
    required this.color,
    required this.bgColor,
  });

  final String name;
  final IconData icon;
  final Color color;
  final Color bgColor;
}

// ─── Notification Model ──────────────────────────────────────────────────────

class NotificationItemModel {
  const NotificationItemModel({
    required this.title,
    required this.message,
    required this.timeAgo,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    this.isRead = false,
    this.isToday = true,
  });

  final String title;
  final String message;
  final String timeAgo;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final bool isRead;
  final bool isToday;
}

// ─── Static Data ─────────────────────────────────────────────────────────────

abstract final class HomeStaticData {
  static const List<SpecialityModel> specialities = [
    SpecialityModel(
      name: 'General',
      icon: Icons.medical_services_outlined,
      color: Color(0xFF2563EB),
      bgColor: Color(0xFFEFF6FF),
    ),
    SpecialityModel(
      name: 'Neurologic',
      icon: Icons.psychology_outlined,
      color: Color(0xFF7C3AED),
      bgColor: Color(0xFFF5F3FF),
    ),
    SpecialityModel(
      name: 'Pediatric',
      icon: Icons.child_care_outlined,
      color: Color(0xFFEC4899),
      bgColor: Color(0xFFFDF2F8),
    ),
    SpecialityModel(
      name: 'Radiology',
      icon: Icons.monitor_heart_outlined,
      color: Color(0xFF0891B2),
      bgColor: Color(0xFFECFEFF),
    ),
    SpecialityModel(
      name: 'Dental',
      icon: Icons.front_hand_outlined,
      color: Color(0xFF059669),
      bgColor: Color(0xFFECFDF5),
    ),
    SpecialityModel(
      name: 'Cardio',
      icon: Icons.favorite_outline,
      color: Color(0xFFDC2626),
      bgColor: Color(0xFFFEF2F2),
    ),
  ];

  static const List<DoctorModel> recommendedDoctors = [
    DoctorModel(
      id: '1',
      name: 'Dr. Randy Wigham',
      speciality: 'General',
      hospital: 'RSUD Gatot Subroto',
      rating: 4.8,
      reviewCount: 4279,
      avatarAsset: '',
      isAvailable: true,
    ),
    DoctorModel(
      id: '2',
      name: 'Dr. Jack Sulivan',
      speciality: 'Neurologic',
      hospital: 'RSUD Gatot Subroto',
      rating: 4.9,
      reviewCount: 3841,
      avatarAsset: '',
      isAvailable: true,
    ),
    DoctorModel(
      id: '3',
      name: 'Dr. Sarah Mitchell',
      speciality: 'Pediatric',
      hospital: 'St. Mary Hospital',
      rating: 4.7,
      reviewCount: 2956,
      avatarAsset: '',
      isAvailable: false,
    ),
    DoctorModel(
      id: '4',
      name: 'Dr. Ahmed Hassan',
      speciality: 'Cardiologist',
      hospital: 'Cairo Medical Center',
      rating: 4.9,
      reviewCount: 5120,
      avatarAsset: '',
      isAvailable: true,
    ),
  ];
}
