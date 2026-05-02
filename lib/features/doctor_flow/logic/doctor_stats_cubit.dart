import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:doctor_appointment/core/utils/result.dart';
import 'package:doctor_appointment/features/doctor_flow/domain/usecases/get_doctor_stats_usecase.dart';
import 'package:doctor_appointment/features/doctor_flow/logic/doctor_stats_state.dart';

class DoctorStatsCubit extends Cubit<DoctorStatsState> {
  final GetDoctorStatsUseCase getDoctorStatsUseCase;

  DoctorStatsCubit({required this.getDoctorStatsUseCase})
      : super(const DoctorStatsInitial());

  Future<void> fetchStats() async {
    emit(const DoctorStatsLoading());
    final result = await getDoctorStatsUseCase();
    
    switch (result) {
      case Success():
        emit(DoctorStatsSuccess(result.data));
      case FailureResult():
        emit(DoctorStatsFailure(result.failure.message));
    }
  }
}
