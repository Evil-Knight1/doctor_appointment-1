import 'package:doctor_appointment/core/errors/failures.dart';

sealed class Result<T> {
  const Result();

  factory Result.success(T data) = Success<T>;
  factory Result.failure(Failure failure) = FailureResult<T>;
}

class Success<T> extends Result<T> {
  final T data;

  const Success(this.data);
}

class FailureResult<T> extends Result<T> {
  final Failure failure;

  const FailureResult(this.failure);
}
