import 'package:doctor_appointment/core/errors/exceptions.dart';
import 'package:doctor_appointment/core/errors/failures.dart';
import 'package:doctor_appointment/core/utils/result.dart';
import 'package:doctor_appointment/features/appointment/data/datasources/appointment_remote_data_source.dart';
import 'package:doctor_appointment/features/appointment/domain/entities/appointment.dart';
import 'package:doctor_appointment/features/appointment/data/models/slot_model.dart';

abstract class AppointmentRepository {
  Future<Result<Appointment>> createAppointment({
    required int doctorId,
    required int slotId,
    required String reason,
    int? paymentMethod,
    double? amount,
  });

  Future<Result<List<Appointment>>> getMyAppointments();
  
  Future<Result<List<SlotModel>>> getDoctorSlots(int doctorId, DateTime date);
}

class AppointmentRepositoryImpl implements AppointmentRepository {
  final AppointmentRemoteDataSource remoteDataSource;

  AppointmentRepositoryImpl(this.remoteDataSource);

  @override
  Future<Result<Appointment>> createAppointment({
    required int doctorId,
    required int slotId,
    required String reason,
    int? paymentMethod,
    double? amount,
  }) async {
    try {
      final result = await remoteDataSource.createAppointment(
        doctorId: doctorId,
        slotId: slotId,
        reason: reason,
        paymentMethod: paymentMethod,
        amount: amount,
      );
      // Currently, AppointmentModel IS the entity, or it extends it.
      // If it doesn't extend it, we'd need a mapper. In this project,
      // models usually extend entities.
      return Result.success(result);
    } on ApiException catch (e) {
      return Result.failure(ServerFailure(e.message));
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<Appointment>>> getMyAppointments() async {
    try {
      final result = await remoteDataSource.getMyAppointments();
      return Result.success(result);
    } on ApiException catch (e) {
      return Result.failure(ServerFailure(e.message));
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<SlotModel>>> getDoctorSlots(int doctorId, DateTime date) async {
    try {
      final result = await remoteDataSource.getDoctorSlots(doctorId, date);
      return Result.success(result);
    } on ApiException catch (e) {
      return Result.failure(ServerFailure(e.message));
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }
}
