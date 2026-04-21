import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:doctor_appointment/core/security/app_permissions.dart';
import 'package:doctor_appointment/features/doctor_details/logic/doctor_details_state.dart';

class DoctorDetailsCubit extends Cubit<DoctorDetailsState> {
  final AppPermissions appPermissions;

  DoctorDetailsCubit({required this.appPermissions})
    : super(const DoctorDetailsInitial());

  Future<void> fetchDoctorDetails(int doctorId) async {
    emit(const DoctorDetailsLoading());
    try {
      // Simulate API fetch
      await Future.delayed(const Duration(seconds: 1));

      final mockDoctor = {
        'id': doctorId,
        'name': 'Dr. Mock',
        'specialty': 'General',
      };
      final mockSlots = ['09:00 AM', '10:00 AM', '11:00 AM'];

      emit(DoctorDetailsLoaded(doctor: mockDoctor, availableSlots: mockSlots));
    } catch (e) {
      emit(DoctorDetailsError(e.toString()));
    }
  }

  bool canBook() {
    return appPermissions.canBookAppointment;
  }
}
