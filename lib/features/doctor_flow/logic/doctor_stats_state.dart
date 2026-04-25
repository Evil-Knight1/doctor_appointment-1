import 'package:doctor_appointment/features/doctor_flow/domain/entities/doctor_stats.dart';

sealed class DoctorStatsState {
  const DoctorStatsState();
}

class DoctorStatsInitial extends DoctorStatsState {
  const DoctorStatsInitial();
}

class DoctorStatsLoading extends DoctorStatsState {
  const DoctorStatsLoading();
}

class DoctorStatsSuccess extends DoctorStatsState {
  final DoctorStats stats;
  const DoctorStatsSuccess(this.stats);
}

class DoctorStatsFailure extends DoctorStatsState {
  final String message;
  const DoctorStatsFailure(this.message);
}
