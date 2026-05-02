import 'package:doctor_appointment/core/errors/exceptions.dart';
import 'package:doctor_appointment/core/errors/failures.dart';
import 'package:doctor_appointment/features/doctors/data/datasources/specializations_remote_data_source.dart';
import 'package:doctor_appointment/features/doctors/domain/entities/specialization.dart';
import 'package:doctor_appointment/features/doctors/domain/repositories/specializations_repository.dart';

class SpecializationsRepositoryImpl implements SpecializationsRepository {
  final SpecializationsRemoteDataSource remoteDataSource;
  SpecializationsRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Specialization>> getSpecializations() async {
    try {
      return await remoteDataSource.getSpecializations();
    } on ApiException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw const ServerFailure('Unexpected error fetching specializations');
    }
  }
}
