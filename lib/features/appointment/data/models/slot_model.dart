class SlotModel {
  final int id;
  final DateTime startTime;
  final DateTime endTime;
  final int durationMinutes;
  final bool isBooked;
  final bool isAvailable;

  const SlotModel({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.durationMinutes,
    required this.isBooked,
    required this.isAvailable,
  });

  factory SlotModel.fromJson(Map<String, dynamic> json) {
    // Support both camelCase (old) and snake_case / alternate keys (new endpoint)
    final rawStart =
        json['startTime'] as String? ?? json['start_time'] as String? ?? '';
    final rawEnd =
        json['endTime'] as String? ?? json['end_time'] as String? ?? '';

    return SlotModel(
      id: (json['id'] as num).toInt(),
      startTime: DateTime.parse(rawStart).toLocal(),
      endTime: DateTime.parse(rawEnd).toLocal(),
      durationMinutes:
          (json['durationMinutes'] as num? ??
                  json['duration_minutes'] as num? ??
                  30)
              .toInt(),
      isBooked: json['isBooked'] as bool? ?? json['is_booked'] as bool? ?? false,
      isAvailable:
          json['isAvailable'] as bool? ??
          json['is_available'] as bool? ??
          !(json['isBooked'] as bool? ?? false),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startTime': startTime.toUtc().toIso8601String(),
      'endTime': endTime.toUtc().toIso8601String(),
      'durationMinutes': durationMinutes,
      'isBooked': isBooked,
      'isAvailable': isAvailable,
    };
  }
}

