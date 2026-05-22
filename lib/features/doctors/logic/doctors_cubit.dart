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
  int? _currentSpecializationId;
  double? _currentMinRating;
  String? _currentSearchTerm;

  Future<void> fetchDoctors({
    int? specializationId,
    double? minRating,
    String? searchTerm,
    int pageNumber = 1,
    int pageSize = 10,
    bool isPagination = false,
  }) async {
    if (_isFetching) return;
    _isFetching = true;

    if (!isPagination) {
      _currentSpecializationId = specializationId;
      _currentMinRating = minRating;
      _currentSearchTerm = searchTerm;
    }

    if (isPagination) {
      if (_currentPage != null && !isClosed) {
        emit(DoctorsPaginationLoading(_currentPage!));
      }
    } else {
      if (!isClosed) emit(const DoctorsLoading());
    }

    final result = await searchDoctorsUseCase(
      SearchDoctorsParams(
        specializationId: specializationId,
        minRating: minRating,
        searchTerm: searchTerm,
        pageNumber: pageNumber,
        pageSize: pageSize,
      ),
    );

    _isFetching = false;

    if (isClosed) return;

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

  void fetchNextPage() {
    if (_currentPage == null || !_currentPage!.hasNextPage || _isFetching) return;

    fetchDoctors(
      specializationId: _currentSpecializationId,
      minRating: _currentMinRating,
      searchTerm: _currentSearchTerm,
      pageNumber: _currentPage!.pageNumber + 1,
      pageSize: _currentPage!.pageSize,
      isPagination: true,
    );
  }
}
