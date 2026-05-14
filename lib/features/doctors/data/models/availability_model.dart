class AvailabilityModel {
  final int id;
  final int dayOfWeek; // 0 = Sunday, 1 = Monday, ..., 6 = Saturday
  final String startTime; // "09:00:00"
  final String endTime; // "17:00:00"
  final bool isAvailable;

  const AvailabilityModel({
    required this.id,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.isAvailable,
  });

  factory AvailabilityModel.fromJson(Map<String, dynamic> json) {
    return AvailabilityModel(
      id: json['id'] as int? ?? 0,
      dayOfWeek: json['dayOfWeek'] as int? ?? 0,
      startTime: json['startTime'] as String? ?? '',
      endTime: json['endTime'] as String? ?? '',
      isAvailable: json['isAvailable'] as bool? ?? false,
    );
  }

  /// Returns the day name (0=Sunday, 1=Monday, ..., 6=Saturday).
  String get dayName {
    const days = [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
    ];
    if (dayOfWeek >= 0 && dayOfWeek < days.length) {
      return days[dayOfWeek];
    }
    return 'Day $dayOfWeek';
  }

  /// Returns a formatted time range like "09:00 AM - 05:00 PM".
  String get timeRange {
    return '${_format(startTime)} - ${_format(endTime)}';
  }

  String _format(String raw) {
    // raw is "HH:mm:ss" — strip seconds and convert to 12-hour
    final parts = raw.split(':');
    if (parts.length < 2) return raw;
    int hour = int.tryParse(parts[0]) ?? 0;
    final minute = parts[1];
    final period = hour >= 12 ? 'PM' : 'AM';
    if (hour == 0) hour = 12;
    if (hour > 12) hour -= 12;
    return '${hour.toString().padLeft(2, '0')}:$minute $period';
  }
}
