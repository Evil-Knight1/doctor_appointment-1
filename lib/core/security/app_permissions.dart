enum AppRole { guest, patient }

class AppPermissions {
  AppRole _currentRole = AppRole.guest; // Default role

  void updateRole(AppRole newRole) {
    _currentRole = newRole;
  }

  AppRole get currentRole => _currentRole;

  bool get canBookAppointment => _currentRole == AppRole.patient;
  bool get canUseFavorites => _currentRole == AppRole.patient;
  bool get canAccessProfile => _currentRole == AppRole.patient;
  bool get canViewCalendar => _currentRole == AppRole.patient;

  // Assuming everyone can view general info (home/doctors list)
  bool get canViewDoctors => true;
}
