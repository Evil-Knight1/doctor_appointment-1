import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:doctor_appointment/core/security/app_permissions.dart';
import 'package:doctor_appointment/features/calendar/logic/calendar_state.dart';

class CalendarCubit extends Cubit<CalendarState> {
  final AppPermissions appPermissions;

  CalendarCubit({required this.appPermissions})
    : super(const CalendarInitial());

  Future<void> fetchEventsForDate(DateTime date) async {
    if (!appPermissions.canViewCalendar) {
      emit(
        const CalendarPermissionDenied(
          'You must be a patient to view the calendar.',
        ),
      );
      return;
    }

    emit(const CalendarLoading());
    try {
      // Simulate fetching appointments for a specific date
      await Future.delayed(const Duration(seconds: 1));

      final mockEvents = ['Checkup at 10:00 AM', 'Dentist at 2:00 PM'];
      emit(CalendarLoaded(mockEvents));
    } catch (e) {
      emit(CalendarError(e.toString()));
    }
  }
}
