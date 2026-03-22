import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:doctor_appointment/core/utils/result.dart';
import 'package:doctor_appointment/features/doctors/domain/usecases/search_doctors_usecase.dart';
import 'package:doctor_appointment/features/doctors/logic/doctors_state.dart';

class DoctorsCubit extends Cubit<DoctorsState> {
  final SearchDoctorsUseCase searchDoctorsUseCase;

  DoctorsCubit({required this.searchDoctorsUseCase})
      : super(const DoctorsInitial());

  Future<void> fetchDoctors({
    String? specialization,
    double? minRating,
    String? searchTerm,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    emit(const DoctorsLoading());
    final result = await searchDoctorsUseCase(
      SearchDoctorsParams(
        specialization: specialization,
        minRating: minRating,
        searchTerm: searchTerm,
        pageNumber: pageNumber,
        pageSize: pageSize,
      ),
    );

    switch (result) {
      case Success():
        emit(DoctorsSuccess(result.data));
      case FailureResult():
        emit(DoctorsFailure(result.failure.message));
    }
  }
}
