import 'package:dio/dio.dart';
import 'package:doctor_appointment/core/errors/exceptions.dart';
import 'package:doctor_appointment/core/errors/failures.dart'
    show NetworkFailure, ServerFailure, UnknownFailure;
import 'package:doctor_appointment/core/utils/result.dart';
import 'package:doctor_appointment/features/doctors/data/datasources/review_remote_data_source.dart';
import 'package:doctor_appointment/features/doctors/domain/entities/review.dart';
import 'package:doctor_appointment/features/doctors/domain/repositories/review_repository.dart';

class ReviewRepositoryImpl implements ReviewRepository {
  final ReviewRemoteDataSource remoteDataSource;

  ReviewRepositoryImpl(this.remoteDataSource);

  @override
  Future<Result<Review>> addReview({
    required int doctorId,
    required int stars,
    required String comment,
  }) async {
    try {
      final response = await remoteDataSource.addReview(
        doctorId: doctorId,
        stars: stars,
        comment: comment,
      );
      return Result.success(response);
    } on ApiException catch (exception) {
      return Result.failure(ServerFailure(exception.message));
    } on DioException catch (exception) {
      return Result.failure(
        NetworkFailure(exception.message ?? 'Network error occurred'),
      );
    } catch (exception) {
      return Result.failure(UnknownFailure(exception.toString()));
    }
  }

  @override
  Future<Result<List<Review>>> getDoctorReviews(int doctorId) async {
    try {
      final response = await remoteDataSource.getDoctorReviews(doctorId);
      return Result.success(response);
    } on ApiException catch (exception) {
      return Result.failure(ServerFailure(exception.message));
    } on DioException catch (exception) {
      return Result.failure(
        NetworkFailure(exception.message ?? 'Network error occurred'),
      );
    } catch (exception) {
      return Result.failure(UnknownFailure(exception.toString()));
    }
  }
}
