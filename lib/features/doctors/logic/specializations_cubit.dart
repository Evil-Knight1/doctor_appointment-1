import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:doctor_appointment/features/doctors/domain/usecases/get_specializations_usecase.dart';
import 'package:doctor_appointment/features/doctors/logic/specializations_state.dart';

class SpecializationsCubit extends Cubit<SpecializationsState> {
  final GetSpecializationsUseCase getSpecializationsUseCase;

  SpecializationsCubit({required this.getSpecializationsUseCase})
      : super(const SpecializationsInitial());

  Future<void> fetchSpecializations() async {
    emit(const SpecializationsLoading());
    try {
      final specializations = await getSpecializationsUseCase();
      
      // Use a Set to ensure unique names as requested
      final uniqueNames = specializations.map((s) => s.name).toSet();
      
      emit(SpecializationsSuccess(specializations, uniqueNames));
    } catch (e) {
      emit(SpecializationsFailure(e.toString()));
    }
  }
}
