import 'package:doctor_appointment/core/utils/result.dart';
import 'package:doctor_appointment/features/doctors/data/datasources/doctors_remote_data_source.dart';
import 'package:doctor_appointment/features/doctors/data/models/availability_model.dart';
import 'package:doctor_appointment/features/doctors/domain/repositories/review_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:doctor_appointment/features/doctors/logic/doctor_details_state.dart';

class DoctorDetailsCubit extends Cubit<DoctorDetailsState> {
  final ReviewRepository reviewRepository;
  final DoctorsRemoteDataSource doctorsRemoteDataSource;
  int? doctorId;

  DoctorDetailsCubit({
    required this.reviewRepository,
    required this.doctorsRemoteDataSource,
  }) : super(DoctorDetailsInitial());

  void loadDoctorDetails(int doctorId) async {
    this.doctorId = doctorId;
    emit(DoctorDetailsLoading());

    // Fetch reviews and availability in parallel — availability failure is non-fatal
    final reviewFuture = reviewRepository.getDoctorReviews(doctorId);
    final availabilityFuture = _fetchAvailabilitySafe(doctorId);

    final reviewResult = await reviewFuture;
    final availability = await availabilityFuture;

    switch (reviewResult) {
      case Success():
        emit(DoctorDetailsLoaded(reviews: reviewResult.data, availability: availability));
      case FailureResult():
        emit(DoctorDetailsError(reviewResult.failure.message));
    }
  }

  Future<List<AvailabilityModel>> _fetchAvailabilitySafe(int doctorId) async {
    try {
      return await doctorsRemoteDataSource.getDoctorAvailability(doctorId);
    } catch (_) {
      return [];
    }
  }

  Future<void> addReview({
    required int doctorId,
    required int stars,
    required String comment,
  }) async {
    final result = await reviewRepository.addReview(
      doctorId: doctorId,
      stars: stars,
      comment: comment,
    );

    if (result is Success) {
      loadDoctorDetails(doctorId);
    }
  }
}
