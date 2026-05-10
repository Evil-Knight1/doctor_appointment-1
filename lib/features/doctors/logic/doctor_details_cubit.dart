import 'package:doctor_appointment/core/utils/result.dart';
import 'package:doctor_appointment/features/doctors/domain/repositories/review_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:doctor_appointment/features/doctors/logic/doctor_details_state.dart';

class DoctorDetailsCubit extends Cubit<DoctorDetailsState> {
  final ReviewRepository reviewRepository;
  int? doctorId;

  DoctorDetailsCubit({required this.reviewRepository})
      : super(DoctorDetailsInitial());

  void loadDoctorDetails(int doctorId) async {
    this.doctorId = doctorId;
    emit(DoctorDetailsLoading());

    final result = await reviewRepository.getDoctorReviews(doctorId);

    switch (result) {
      case Success():
        emit(DoctorDetailsLoaded(reviews: result.data));
      case FailureResult():
        emit(DoctorDetailsError(result.failure.message));
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
      loadDoctorDetails(doctorId); // Reload reviews after adding one
    }
  }
}
