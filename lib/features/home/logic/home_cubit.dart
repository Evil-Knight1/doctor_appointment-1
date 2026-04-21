import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:doctor_appointment/features/home/logic/home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(const HomeInitial());

  Future<void> fetchHomeData() async {
    emit(const HomeLoading());
    try {
      // Simulate fetching banners and categories
      await Future.delayed(const Duration(seconds: 1));

      final mockBanners = [
        'assets/images/banner1.png',
        'assets/images/banner2.png',
      ];
      final mockCategories = [
        'Cardiology',
        'Neurology',
        'Orthopedics',
        'Pediatrics',
      ];

      emit(HomeLoaded(banners: mockBanners, categories: mockCategories));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }
}
