import 'package:doctor_appointment/core/errors/exceptions.dart';
import 'package:doctor_appointment/core/errors/failures.dart';
import 'package:doctor_appointment/features/doctor_flow/data/datasources/doctor_stats_remote_data_source.dart';
import 'package:doctor_appointment/features/doctor_flow/domain/entities/doctor_stats.dart';
import 'package:doctor_appointment/features/doctor_flow/domain/repositories/doctor_stats_repository.dart';

class DoctorStatsRepositoryImpl implements DoctorStatsRepository {
  final DoctorStatsRemoteDataSource remoteDataSource;
  DoctorStatsRepositoryImpl(this.remoteDataSource);

  @override
  Future<DoctorStats> getDoctorStats() async {
    try {
      return await remoteDataSource.getDoctorStats();
    } on ApiException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw const ServerFailure('Unexpected error fetching statistics');
    }
  }
}
