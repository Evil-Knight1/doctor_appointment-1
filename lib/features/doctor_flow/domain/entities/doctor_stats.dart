class DoctorStats {
  final double totalRevenue;
  final double todayRevenue;
  final int totalAppointments;
  final int completedAppointments;
  final int pendingAppointments;
  final int cancelledAppointments;
  final double averageRating;
  final int totalReviews;
  final int totalPatients;

  const DoctorStats({
    required this.totalRevenue,
    required this.todayRevenue,
    required this.totalAppointments,
    required this.completedAppointments,
    required this.pendingAppointments,
    required this.cancelledAppointments,
    required this.averageRating,
    required this.totalReviews,
    required this.totalPatients,
  });
}
