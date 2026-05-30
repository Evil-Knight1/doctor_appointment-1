import 'package:doctor_appointment/core/utils/result.dart';
import 'package:doctor_appointment/features/doctors/domain/entities/doctors_page.dart';
import 'package:doctor_appointment/features/doctors/domain/repositories/doctors_repository.dart';

class SearchDoctorsUseCase {
  final DoctorsRepository repository;

  const SearchDoctorsUseCase(this.repository);

  Future<Result<DoctorsPage>> call(SearchDoctorsParams params) {
    return repository.searchDoctors(
      specializationId: params.specializationId,
      minRating: params.minRating,
      searchTerm: params.searchTerm,
      userLatitude: params.userLatitude,
      userLongitude: params.userLongitude,
      maxDistanceInKm: params.maxDistanceInKm,
      pageNumber: params.pageNumber,
      pageSize: params.pageSize,
    );
  }
}

class SearchDoctorsParams {
  final int? specializationId;
  final double? minRating;
  final String? searchTerm;
  final double? userLatitude;
  final double? userLongitude;
  final double? maxDistanceInKm;
  final int pageNumber;
  final int pageSize;

  const SearchDoctorsParams({
    this.specializationId,
    this.minRating,
    this.searchTerm,
    this.userLatitude,
    this.userLongitude,
    this.maxDistanceInKm = 10.0,
    this.pageNumber = 1,
    this.pageSize = 10,
  });
}
