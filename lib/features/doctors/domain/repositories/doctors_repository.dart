import 'package:doctor_appointment/core/utils/result.dart';
import 'package:doctor_appointment/features/doctors/domain/entities/doctors_page.dart';

abstract class DoctorsRepository {
  Future<Result<DoctorsPage>> searchDoctors({
    String? specialization,
    double? minRating,
    String? searchTerm,
    int pageNumber,
    int pageSize,
  });
}
