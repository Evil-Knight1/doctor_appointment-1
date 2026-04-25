import 'package:doctor_appointment/core/errors/exceptions.dart';
import 'package:doctor_appointment/core/errors/failures.dart';
import 'package:doctor_appointment/core/utils/result.dart';
import 'package:doctor_appointment/features/doctor_flow/data/datasources/doctor_stats_remote_data_source.dart';
import 'package:doctor_appointment/features/doctor_flow/domain/entities/doctor_stats.dart';
import 'package:doctor_appointment/features/doctor_flow/domain/repositories/doctor_stats_repository.dart';
import 'package:doctor_appointment/features/doctors/domain/entities/doctor.dart';
import 'package:doctor_appointment/features/appointment/domain/entities/appointment.dart';

class DoctorStatsRepositoryImpl implements DoctorStatsRepository {
  final DoctorStatsRemoteDataSource remoteDataSource;
  DoctorStatsRepositoryImpl(this.remoteDataSource);

  @override
  Future<Result<DoctorStats>> getDoctorStats() async {
    try {
      final stats = await remoteDataSource.getDoctorStats();
      return Result.success(stats);
    } on ApiException catch (e) {
      return Result.failure(ServerFailure(e.message));
    } catch (e) {
      return Result.failure(const ServerFailure('Unexpected error fetching statistics'));
    }
  }

  @override
  Future<Result<Doctor>> getDoctorProfile() async {
    try {
      final profile = await remoteDataSource.getDoctorProfile();
      return Result.success(profile);
    } on ApiException catch (e) {
      return Result.failure(ServerFailure(e.message));
    } catch (e) {
      return Result.failure(const ServerFailure('Unexpected error fetching profile'));
    }
  }

  @override
  Future<Result<List<Appointment>>> getDoctorAppointments() async {
    try {
      final appointments = await remoteDataSource.getDoctorAppointments();
      return Result.success(appointments);
    } on ApiException catch (e) {
      return Result.failure(ServerFailure(e.message));
    } catch (e) {
      return Result.failure(const ServerFailure('Unexpected error fetching appointments'));
    }
  }
}
