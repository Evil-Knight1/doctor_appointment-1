import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:doctor_appointment/core/utils/result.dart';
import 'package:doctor_appointment/features/doctor_flow/domain/usecases/get_doctor_monthly_revenue_usecase.dart';
import 'package:doctor_appointment/features/doctor_flow/domain/usecases/get_doctor_daily_revenue_usecase.dart';
import 'package:doctor_appointment/features/doctor_flow/logic/doctor_revenue_state.dart';

class DoctorRevenueCubit extends Cubit<DoctorRevenueState> {
  final GetDoctorMonthlyRevenueUseCase getDoctorMonthlyRevenueUseCase;
  final GetDoctorDailyRevenueUseCase getDoctorDailyRevenueUseCase;

  DoctorRevenueCubit({
    required this.getDoctorMonthlyRevenueUseCase,
    required this.getDoctorDailyRevenueUseCase,
  }) : super(DoctorRevenueInitial());

  Future<void> fetchRevenueData({int? year, int? month}) async {
    final targetYear = year ?? DateTime.now().year;
    final targetMonth = month ?? DateTime.now().month;

    emit(DoctorRevenueLoading());

    final monthlyResult = await getDoctorMonthlyRevenueUseCase(targetYear);
    final dailyResult = await getDoctorDailyRevenueUseCase(targetYear, targetMonth);

    switch ((monthlyResult, dailyResult)) {
      case (Success(data: final monthly), Success(data: final daily)):
        emit(DoctorRevenueSuccess(
          monthlyRevenues: monthly,
          dailyRevenues: daily,
        ));
      case (FailureResult(failure: final f), _):
        emit(DoctorRevenueFailure(f.message));
      case (_, FailureResult(failure: final f)):
        emit(DoctorRevenueFailure(f.message));
    }
  }
}
