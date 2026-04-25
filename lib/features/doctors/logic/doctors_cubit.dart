import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:doctor_appointment/core/utils/result.dart';
import 'package:doctor_appointment/features/doctors/domain/usecases/search_doctors_usecase.dart';
import 'package:doctor_appointment/features/doctors/logic/doctors_state.dart';
import 'package:doctor_appointment/features/doctors/domain/entities/doctors_page.dart';

class DoctorsCubit extends Cubit<DoctorsState> {
  final SearchDoctorsUseCase searchDoctorsUseCase;

  DoctorsCubit({required this.searchDoctorsUseCase})
      : super(const DoctorsInitial());

  DoctorsPage? _currentPage;
  bool _isFetching = false;

  Future<void> fetchDoctors({
    String? specialization,
    double? minRating,
    String? searchTerm,
    int pageNumber = 1,
    int pageSize = 10,
    bool isPagination = false,
  }) async {
    if (_isFetching) return;
    _isFetching = true;

    if (isPagination) {
      if (_currentPage != null) {
        emit(DoctorsPaginationLoading(_currentPage!));
      }
    } else {
      emit(const DoctorsLoading());
    }

    final result = await searchDoctorsUseCase(
      SearchDoctorsParams(
        specialization: specialization,
        minRating: minRating,
        searchTerm: searchTerm,
        pageNumber: pageNumber,
        pageSize: pageSize,
      ),
    );

    _isFetching = false;

    switch (result) {
      case Success():
        if (isPagination && _currentPage != null) {
          final newItems = [..._currentPage!.items, ...result.data.items];
          _currentPage = DoctorsPage(
            items: newItems,
            totalCount: result.data.totalCount,
            pageNumber: result.data.pageNumber,
            pageSize: result.data.pageSize,
            totalPages: result.data.totalPages,
            hasPreviousPage: result.data.hasPreviousPage,
            hasNextPage: result.data.hasNextPage,
          );
        } else {
          _currentPage = result.data;
        }
        emit(DoctorsSuccess(_currentPage!));
      case FailureResult():
        emit(DoctorsFailure(result.failure.message));
    }
  }

  void fetchNextPage({
    String? specialization,
    double? minRating,
    String? searchTerm,
  }) {
    if (_currentPage == null || !_currentPage!.hasNextPage || _isFetching) return;

    fetchDoctors(
      specialization: specialization,
      minRating: minRating,
      searchTerm: searchTerm,
      pageNumber: _currentPage!.pageNumber + 1,
      pageSize: _currentPage!.pageSize,
      isPagination: true,
    );
  }
}
