import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:doctor_appointment/features/doctors/logic/doctor_details_state.dart';

class DoctorDetailsCubit extends Cubit<DoctorDetailsState> {
  DoctorDetailsCubit() : super(DoctorDetailsInitial());

  void loadDoctorDetails(String doctorId) async {
    emit(DoctorDetailsLoading());
    try {
      // Simulate network request
      await Future.delayed(const Duration(seconds: 1));
      
      // Mocked reviews for now as backend endpoint isn't fully set up with reviews yet
      final mockReviews = [
        {
          'name': 'Jane Cooper',
          'text': 'As someone who lives in a remote area, this telemedicine app has been a game changer. I can easily schedule virtual appointments.',
          'stars': 5,
        },
        {
          'name': 'Robert Fox',
          'text': 'I was initially skeptical but this app has exceeded my expectations. The doctors are highly qualified and provide excellent care.',
          'stars': 5,
        },
        {
          'name': 'Jacob Jones',
          'text': 'Very professional team. Booking was seamless and the doctor was punctual and thorough during consultation.',
          'stars': 5,
        },
      ];

      emit(DoctorDetailsLoaded(reviews: mockReviews));
    } catch (e) {
      emit(DoctorDetailsError(e.toString()));
    }
  }
}
