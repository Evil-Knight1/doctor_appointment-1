import 'package:dio/dio.dart';
import 'package:doctor_appointment/core/errors/exceptions.dart';
import 'package:doctor_appointment/core/errors/failures.dart';
import 'package:doctor_appointment/core/utils/result.dart';
import 'package:doctor_appointment/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:doctor_appointment/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:doctor_appointment/features/auth/domain/entities/auth_response.dart';
import 'package:doctor_appointment/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl(this.remoteDataSource, this.localDataSource);

  @override
  Future<Result<AuthResponse>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await remoteDataSource.login(
        email: email,
        password: password,
      );
      await localDataSource.cacheAuthSession(response);
      return Result.success(response);
    } on ApiException catch (exception) {
      return Result.failure(
        ServerFailure(
          exception.message,
          statusCode: exception.statusCode,
          fieldErrors: exception.fieldErrors,
        ),
      );
    } on DioException catch (exception) {
      return Result.failure(_mapDioFailure(exception));
    } catch (_) {
      return Result.failure(const UnknownFailure('Unexpected error occurred'));
    }
  }

  @override
  Future<Result<AuthResponse>> registerPatient({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    DateTime? dateOfBirth,
    String? gender,
    String? address,
    String? profilePicturePath,
  }) async {
    try {
      final response = await remoteDataSource.registerPatient(
        fullName: fullName,
        email: email,
        phone: phone,
        password: password,
        dateOfBirth: dateOfBirth,
        gender: gender,
        address: address,
        profilePicturePath: profilePicturePath,
      );
      await localDataSource.cacheAuthSession(response);
      return Result.success(response);
    } on ApiException catch (exception) {
      return Result.failure(
        ServerFailure(
          exception.message,
          statusCode: exception.statusCode,
          fieldErrors: exception.fieldErrors,
        ),
      );
    } on DioException catch (exception) {
      return Result.failure(_mapDioFailure(exception));
    } catch (_) {
      return Result.failure(const UnknownFailure('Unexpected error occurred'));
    }
  }

  @override
  Future<Result<AuthResponse>> refreshToken({
    required String token,
    required String refreshToken,
  }) async {
    try {
      final response = await remoteDataSource.refreshToken(
        token: token,
        refreshToken: refreshToken,
      );
      await localDataSource.cacheAuthSession(response);
      return Result.success(response);
    } on ApiException catch (exception) {
      return Result.failure(
        ServerFailure(
          exception.message,
          statusCode: exception.statusCode,
          fieldErrors: exception.fieldErrors,
        ),
      );
    } on DioException catch (exception) {
      return Result.failure(_mapDioFailure(exception));
    } catch (_) {
      return Result.failure(const UnknownFailure('Unexpected error occurred'));
    }
  }

  @override
  Future<Result<AuthResponse?>> getCachedSession() async {
    try {
      final session = await localDataSource.getCachedSession();
      return Result.success(session);
    } catch (_) {
      return Result.failure(const UnknownFailure('Failed to read session'));
    }
  }

  @override
  Future<Result<AuthResponse>> registerDoctor({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required int specializationId,
    required int experienceYears,
    required String licenseId,
    required String clinicAddress,
    required String hospitalName,
    DateTime? dateOfBirth,
    String? gender,
    String? bio,
    String? profilePicturePath,
    List<String>? clinicImagesPaths,
  }) async {
    try {
      final response = await remoteDataSource.registerDoctor(
        fullName: fullName,
        email: email,
        phone: phone,
        password: password,
        specializationId: specializationId,
        experienceYears: experienceYears,
        licenseId: licenseId,
        clinicAddress: clinicAddress,
        hospitalName: hospitalName,
        dateOfBirth: dateOfBirth,
        gender: gender,
        bio: bio,
        profilePicturePath: profilePicturePath,
        clinicImagesPaths: clinicImagesPaths,
      );
      await localDataSource.cacheAuthSession(response);
      return Result.success(response);
    } on ApiException catch (exception) {
      return Result.failure(
        ServerFailure(
          exception.message,
          statusCode: exception.statusCode,
          fieldErrors: exception.fieldErrors,
        ),
      );
    } on DioException catch (exception) {
      return Result.failure(_mapDioFailure(exception));
    } catch (e) {
      return Result.failure(UnknownFailure(e.toString()));
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
    final message =
        _extractMessage(response?.data) ??
        exception.message ??
        'Request failed';

    if (statusCode == 409) {
      return const ServerFailure('This email or phone number is already taken');
    }

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
  Future<Result<bool>> updateFcmToken({required String fcmToken}) async {
    try {
      final success = await remoteDataSource.updateFcmToken(fcmToken: fcmToken);
      return Result.success(success);
    } on ApiException catch (exception) {
      return Result.failure(
        ServerFailure(exception.message, statusCode: exception.statusCode),
      );
    } on DioException catch (exception) {
      return Result.failure(_mapDioFailure(exception));
    } catch (e) {
      return Result.failure(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> forgotPassword({required String email}) async {
    try {
      await remoteDataSource.forgotPassword(email: email);
      return Result.success(null);
    } on ApiException catch (exception) {
      return Result.failure(
        ServerFailure(
          exception.message,
          statusCode: exception.statusCode,
          fieldErrors: exception.fieldErrors,
        ),
      );
    } on DioException catch (exception) {
      return Result.failure(_mapDioFailure(exception));
    } catch (e) {
      return Result.failure(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      await remoteDataSource.verifyOtp(email: email, otp: otp);
      return Result.success(null);
    } on ApiException catch (exception) {
      return Result.failure(
        ServerFailure(
          exception.message,
          statusCode: exception.statusCode,
          fieldErrors: exception.fieldErrors,
        ),
      );
    } on DioException catch (exception) {
      return Result.failure(_mapDioFailure(exception));
    } catch (e) {
      return Result.failure(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> resetPassword({
    required String email,
    required String token,
    required String newPassword,
  }) async {
    try {
      await remoteDataSource.resetPassword(
        email: email,
        token: token,
        newPassword: newPassword,
      );
      return Result.success(null);
    } on ApiException catch (exception) {
      return Result.failure(
        ServerFailure(
          exception.message,
          statusCode: exception.statusCode,
          fieldErrors: exception.fieldErrors,
        ),
      );
    } on DioException catch (exception) {
      return Result.failure(_mapDioFailure(exception));
    } catch (e) {
      return Result.failure(UnknownFailure(e.toString()));
    }
  }
}
