import 'package:doctor_appointment/features/doctors/domain/entities/specialization.dart';
import 'package:doctor_appointment/features/doctors/domain/repositories/specializations_repository.dart';

class GetSpecializationsUseCase {
  final SpecializationsRepository repository;
  const GetSpecializationsUseCase(this.repository);

  Future<List<Specialization>> call() => repository.getSpecializations();
}
