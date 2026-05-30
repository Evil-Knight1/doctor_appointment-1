import 'package:doctor_appointment/core/utils/result.dart';
import 'package:doctor_appointment/features/doctors/domain/entities/doctor.dart';

abstract class SearchByLocationRepository {
  Future<Result<List<Doctor>>> searchByLocation({
    required String query,
    double? lat,
    double? lng,
  });
}
