import 'package:dio/dio.dart';
import 'package:doctor_appointment/core/errors/exceptions.dart';
import 'package:doctor_appointment/core/errors/failures.dart';
import 'package:doctor_appointment/core/utils/result.dart';
import 'package:doctor_appointment/features/doctors/data/datasources/doctors_remote_data_source.dart';
import 'package:doctor_appointment/features/doctors/domain/entities/doctors_page.dart';
import 'package:doctor_appointment/features/doctors/domain/repositories/doctors_repository.dart';

class DoctorsRepositoryImpl implements DoctorsRepository {
  final DoctorsRemoteDataSource remoteDataSource;

  DoctorsRepositoryImpl(this.remoteDataSource);

  @override
  Future<Result<DoctorsPage>> searchDoctors({
    String? specialization,
    double? minRating,
    String? searchTerm,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    try {
      final response = await remoteDataSource.searchDoctors(
        specialization: specialization,
        minRating: minRating,
        searchTerm: searchTerm,
        pageNumber: pageNumber,
        pageSize: pageSize,
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
