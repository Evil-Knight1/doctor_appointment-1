import 'package:flutter/material.dart';

class SpecialityModel {
  final String name;
  final IconData icon;
  final Color color;
  final Color bgColor;
  final int? specializationId;

  const SpecialityModel({
    required this.name,
    required this.icon,
    required this.color,
    required this.bgColor,
    this.specializationId,
  });
}

class NotificationItemModel {
  final String title;
  final String message;
  final String timeAgo;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final bool isRead;
  final bool isToday;

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
}
