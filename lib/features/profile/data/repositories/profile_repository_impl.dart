import 'package:dio/dio.dart';
import 'package:doctor_appointment/core/errors/exceptions.dart';
import 'package:doctor_appointment/core/errors/failures.dart';
import 'package:doctor_appointment/core/utils/result.dart';
import 'package:doctor_appointment/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:doctor_appointment/features/profile/domain/entities/patient_profile.dart';
import 'package:doctor_appointment/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl(this.remoteDataSource);

  @override
  Future<Result<PatientProfile>> getPatientProfile() async {
    try {
      final response = await remoteDataSource.getPatientProfile();
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
  Future<Result<PatientProfile>> updatePatientProfile({
    required String fullName,
    required String phone,
    DateTime? dateOfBirth,
    String? gender,
    String? address,
    String? profilePicturePath,
  }) async {
    try {
      final response = await remoteDataSource.updatePatientProfile(
        fullName: fullName,
        phone: phone,
        dateOfBirth: dateOfBirth,
        gender: gender,
        address: address,
        profilePicturePath: profilePicturePath,
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

  Failure _mapDioFailure(DioException exception) {
    if (exception.type == DioExceptionType.connectionTimeout ||
        exception.type == DioExceptionType.sendTimeout ||
        exception.type == DioExceptionType.receiveTimeout ||
        exception.type == DioExceptionType.connectionError) {
      return const NetworkFailure('Please check your internet connection');
    }

    final response = exception.response;
    final statusCode = response?.statusCode;
    final message = _extractMessage(response?.data) ??
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
}
