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
    return SlotModel(
      id: json['id'] as int,
      startTime: DateTime.parse(json['startTime'] as String).toLocal(),
      endTime: DateTime.parse(json['endTime'] as String).toLocal(),
      durationMinutes: json['durationMinutes'] as int,
      isBooked: json['isBooked'] as bool,
      isAvailable: json['isAvailable'] as bool,
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
