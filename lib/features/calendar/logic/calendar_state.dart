abstract class CalendarState {
  const CalendarState();
}

class CalendarInitial extends CalendarState {
  const CalendarInitial();
}

class CalendarLoading extends CalendarState {
  const CalendarLoading();
}

class CalendarLoaded extends CalendarState {
  final List<dynamic> events;

  const CalendarLoaded(this.events);
}

class CalendarError extends CalendarState {
  final String message;

  const CalendarError(this.message);
}

class CalendarPermissionDenied extends CalendarState {
  final String message;

  const CalendarPermissionDenied(this.message);
}
