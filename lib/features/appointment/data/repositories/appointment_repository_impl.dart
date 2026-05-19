import 'package:dio/dio.dart';
import 'package:doctor_appointment/core/errors/exceptions.dart';
import 'package:doctor_appointment/core/errors/failures.dart';
import 'package:doctor_appointment/core/utils/result.dart';
import 'package:doctor_appointment/features/appointment/data/datasources/appointment_remote_data_source.dart';
import 'package:doctor_appointment/features/appointment/data/models/appointment_model.dart';
import 'package:doctor_appointment/features/appointment/data/models/slot_model.dart';
import 'package:doctor_appointment/features/appointment/domain/entities/appointment.dart';
import 'package:doctor_appointment/features/appointment/domain/repositories/appointment_repository.dart';
import 'package:doctor_appointment/features/doctors/data/datasources/doctors_remote_data_source.dart';
import 'package:doctor_appointment/features/doctors/data/models/doctor_api_model.dart';

class AppointmentRepositoryImpl implements AppointmentRepository {
  final AppointmentRemoteDataSource remoteDataSource;
  final DoctorsRemoteDataSource doctorsDataSource;

  AppointmentRepositoryImpl(this.remoteDataSource, this.doctorsDataSource);

  @override
  Future<Result<Appointment>> createAppointment({
    required int doctorId,
    required int slotId,
    required String reason,
    int? paymentMethod,
    double? amount,
    int? type,
  }) async {
    try {
      final response = await remoteDataSource.createAppointment(
        doctorId: doctorId,
        slotId: slotId,
        reason: reason,
        paymentMethod: paymentMethod,
        amount: amount,
        type: type,
      );
      return Result.success(response);
    } on ApiException catch (exception) {
      return Result.failure(
        ServerFailure(exception.message, statusCode: exception.statusCode),
      );
    } on DioException catch (exception) {
      return Result.failure(_mapDioFailure(exception));
    } catch (_) {
      return Result.failure(const UnknownFailure('Unexpected error occurred'));
    }
  }

  @override
  Future<Result<List<Appointment>>> getMyAppointments() async {
    try {
      final appointments = await remoteDataSource.getMyAppointments();

      // Collect unique doctor IDs that need enrichment
      final uniqueDoctorIds = appointments
          .where((a) => a.doctorId != 0)
          .map((a) => a.doctorId)
          .toSet();

      // Fetch all doctor details in parallel (with a simple cache)
      final Map<int, DoctorApiModel> doctorCache = {};
      await Future.wait(
        uniqueDoctorIds.map((id) async {
          try {
            doctorCache[id] = await doctorsDataSource.getDoctorById(id);
          } catch (_) {
            // Skip enrichment for this doctor if the call fails
          }
        }),
      );

      // Enrich each appointment with doctor data
      final enriched = appointments.map((a) {
        final doctor = doctorCache[a.doctorId];
        if (doctor == null) return a;
        return AppointmentModel(
          id: a.id,
          patientId: a.patientId,
          patientName: a.patientName,
          doctorId: a.doctorId,
          doctorName: doctor.fullName,
          startTime: a.startTime,
          endTime: a.endTime,
          reason: a.reason,
          status: a.status,
          isPaid: a.isPaid,
          paymentMethod: a.paymentMethod,
          paymentStatus: a.paymentStatus,
          paymentTransactionId: a.paymentTransactionId,
          paymentDate: a.paymentDate,
          amount: a.amount,
          doctorNotes: a.doctorNotes,
          specializationName: doctor.specialization.name,
          doctorProfilePicture: doctor.profilePictureUrl,
          createdAt: a.createdAt,
        );
      }).toList();

      return Result.success(enriched);
    } on ApiException catch (exception) {
      return Result.failure(
        ServerFailure(exception.message, statusCode: exception.statusCode),
      );
    } on DioException catch (exception) {
      return Result.failure(_mapDioFailure(exception));
    } catch (_) {
      return Result.failure(const UnknownFailure('Unexpected error occurred'));
    }
  }


  Failure _mapDioFailure(DioException exception) {
    if (exception.type == DioExceptionType.connectionTimeout ||
        exception.type == DioExceptionType.sendTimeout ||
        exception.type == DioExceptionType.receiveTimeout ||
        exception.type == DioExceptionType.connectionError) {
      return const NetworkFailure('Please check your internet connection');
    }

    final response = exception.response;
    final statusCode = response?.statusCode;

    // ignore: avoid_print
    print('[AppointmentRepo] HTTP $statusCode error body: ${response?.data}');

    final message =
        _extractMessage(response?.data) ??
        exception.message ??
        'Request failed';

    return ServerFailure(message, statusCode: statusCode);
  }

  String? _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      final message = data['message'];
      if (message is String && message.trim().isNotEmpty) {
        return message;
      }
      final errors = data['errors'];
      if (errors is List && errors.isNotEmpty) {
        return errors.map((e) => e.toString()).join(', ');
      }
    }
    return null;
  }

  @override
  Future<Result<List<SlotModel>>> getDoctorSlots(int doctorId, DateTime date) async {
    try {
      final response = await remoteDataSource.getDoctorSlots(doctorId, date);
      return Result.success(response);
    } on ApiException catch (exception) {
      return Result.failure(
        ServerFailure(exception.message, statusCode: exception.statusCode),
      );
    } on DioException catch (exception) {
      return Result.failure(_mapDioFailure(exception));
    } catch (_) {
      return Result.failure(const UnknownFailure('Unexpected error occurred'));
    }
  }

  @override
  Future<Result<void>> cancelAppointment(int appointmentId) async {
    try {
      await remoteDataSource.cancelAppointment(appointmentId);
      return Result.success(null);
    } on ApiException catch (exception) {
      return Result.failure(
        ServerFailure(exception.message, statusCode: exception.statusCode),
      );
    } on DioException catch (exception) {
      return Result.failure(_mapDioFailure(exception));
    } catch (_) {
      return Result.failure(const UnknownFailure('Unexpected error occurred'));
    }
  }
}
