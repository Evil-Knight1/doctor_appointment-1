import 'package:doctor_appointment/features/doctors/domain/entities/specialization.dart';

abstract class SpecializationsRepository {
  Future<List<Specialization>> getSpecializations();
}
