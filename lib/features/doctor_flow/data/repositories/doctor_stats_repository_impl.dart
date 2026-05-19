import 'package:doctor_appointment/core/errors/exceptions.dart';
import 'package:doctor_appointment/core/errors/failures.dart';
import 'package:doctor_appointment/core/utils/result.dart';
import 'package:doctor_appointment/features/doctor_flow/data/datasources/doctor_stats_remote_data_source.dart';
import 'package:doctor_appointment/features/doctor_flow/domain/entities/doctor_stats.dart';
import 'package:doctor_appointment/features/doctor_flow/domain/repositories/doctor_stats_repository.dart';
import 'package:doctor_appointment/features/doctors/domain/entities/doctor.dart';
import 'package:doctor_appointment/features/appointment/domain/entities/appointment.dart';
import 'package:doctor_appointment/features/doctor_flow/domain/entities/doctor_monthly_revenue.dart';
import 'package:doctor_appointment/features/doctor_flow/domain/entities/doctor_daily_revenue.dart';
import 'package:doctor_appointment/features/doctors/data/models/availability_model.dart';

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

  @override
  Future<Result<Doctor>> updateDoctorProfile(Map<String, dynamic> data) async {
    try {
      final profile = await remoteDataSource.updateDoctorProfile(data);
      return Result.success(profile);
    } on ApiException catch (e) {
      return Result.failure(ServerFailure(e.message));
    } catch (e) {
      return Result.failure(const ServerFailure('Unexpected error updating profile'));
    }
  }

  @override
  Future<Result<Appointment>> updateAppointmentStatus(int appointmentId, int status, {String? notes}) async {
    try {
      final appointment = await remoteDataSource.updateAppointmentStatus(appointmentId, status, notes: notes);
      return Result.success(appointment);
    } on ApiException catch (e) {
      return Result.failure(ServerFailure(e.message));
    } catch (e) {
      return Result.failure(const ServerFailure('Unexpected error updating appointment status'));
    }
  }

  @override
  Future<Result<List<DoctorMonthlyRevenue>>> getMonthlyRevenue(int year) async {
    try {
      final revenue = await remoteDataSource.getMonthlyRevenue(year);
      return Result.success(revenue);
    } on ApiException catch (e) {
      return Result.failure(ServerFailure(e.message));
    } catch (e) {
      return Result.failure(const ServerFailure('Unexpected error fetching monthly revenue'));
    }
  }

  @override
  Future<Result<List<DoctorDailyRevenue>>> getDailyRevenue(int year, int month) async {
    try {
      final revenue = await remoteDataSource.getDailyRevenue(year, month);
      return Result.success(revenue);
    } on ApiException catch (e) {
      return Result.failure(ServerFailure(e.message));
    } catch (e) {
      return Result.failure(const ServerFailure('Unexpected error fetching daily revenue'));
    }
  }

  @override
  Future<Result<AvailabilityModel>> addAvailability(Map<String, dynamic> data) async {
    try {
      final res = await remoteDataSource.addAvailability(data);
      return Result.success(res);
    } on ApiException catch (e) {
      return Result.failure(ServerFailure(e.message));
    } catch (e) {
      return Result.failure(const ServerFailure('Unexpected error adding availability'));
    }
  }

  @override
  Future<Result<AvailabilityModel>> updateAvailability(int availabilityId, Map<String, dynamic> data) async {
    try {
      final res = await remoteDataSource.updateAvailability(availabilityId, data);
      return Result.success(res);
    } on ApiException catch (e) {
      return Result.failure(ServerFailure(e.message));
    } catch (e) {
      return Result.failure(const ServerFailure('Unexpected error updating availability'));
    }
  }

  @override
  Future<Result<List<AvailabilityModel>>> getDoctorAvailability(int doctorId) async {
    try {
      final res = await remoteDataSource.getDoctorAvailability(doctorId);
      return Result.success(res);
    } on ApiException catch (e) {
      return Result.failure(ServerFailure(e.message));
    } catch (e) {
      return Result.failure(const ServerFailure('Unexpected error fetching availability'));
    }
  }
}
