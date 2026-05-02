import 'package:doctor_appointment/features/doctor_flow/domain/entities/doctor_stats.dart';

class DoctorStatsModel extends DoctorStats {
  const DoctorStatsModel({
    required super.totalRevenue,
    required super.todayRevenue,
    required super.totalAppointments,
    required super.completedAppointments,
    required super.pendingAppointments,
    required super.cancelledAppointments,
    required super.averageRating,
    required super.totalReviews,
    required super.totalPatients,
  });

  factory DoctorStatsModel.fromJson(Map<String, dynamic> json) {
    return DoctorStatsModel(
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0.0,
      todayRevenue: (json['todayRevenue'] as num?)?.toDouble() ?? 0.0,
      totalAppointments: json['totalAppointments'] as int? ?? 0,
      completedAppointments: json['completedAppointments'] as int? ?? 0,
      pendingAppointments: json['pendingAppointments'] as int? ?? 0,
      cancelledAppointments: json['cancelledAppointments'] as int? ?? 0,
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: json['totalReviews'] as int? ?? 0,
      totalPatients: json['totalPatients'] as int? ?? 0,
    );
  }
}
