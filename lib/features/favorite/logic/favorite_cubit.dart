import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:doctor_appointment/core/security/app_permissions.dart';
import 'package:doctor_appointment/features/favorite/logic/favorite_state.dart';

class FavoriteCubit extends Cubit<FavoriteState> {
  final AppPermissions appPermissions;

  FavoriteCubit({required this.appPermissions})
    : super(const FavoriteInitial());

  Future<void> fetchFavorites() async {
    // Permission Check
    if (!appPermissions.canUseFavorites) {
      emit(
        const FavoritePermissionDenied(
          'You must be logged in as a patient to view favorites.',
        ),
      );
      return;
    }

    emit(const FavoriteLoading());
    try {
      // Simulate API fetch delay
      await Future.delayed(const Duration(seconds: 1));

      // Return empty or mock list for now until real API is attached
      emit(const FavoriteLoaded([]));
    } catch (e) {
      emit(FavoriteError(e.toString()));
    }
  }

  Future<void> toggleFavorite(int doctorId) async {
    if (!appPermissions.canUseFavorites) {
      emit(
        const FavoritePermissionDenied(
          'You must be logged in as a patient to add favorites.',
        ),
      );
      return;
    }

    // Logic to toggle favorite via API
    // Re-fetch or update list after state changes
  }
}
