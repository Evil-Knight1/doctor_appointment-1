import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:doctor_appointment/features/doctor_flow/domain/usecases/get_doctor_stats_usecase.dart';
import 'package:doctor_appointment/features/doctor_flow/logic/doctor_stats_state.dart';

class DoctorStatsCubit extends Cubit<DoctorStatsState> {
  final GetDoctorStatsUseCase getDoctorStatsUseCase;

  DoctorStatsCubit({required this.getDoctorStatsUseCase})
      : super(const DoctorStatsInitial());

  Future<void> fetchStats() async {
    emit(const DoctorStatsLoading());
    try {
      final stats = await getDoctorStatsUseCase();
      emit(DoctorStatsSuccess(stats));
    } catch (e) {
      emit(DoctorStatsFailure(e.toString()));
    }
  }
}
