class Appointment {
  final int id;
  final int patientId;
  final String patientName;
  final int doctorId;
  final String doctorName;
  final DateTime startTime;
  final DateTime endTime;
  final String reason;
  final int status;
  final bool isPaid;
  final int? paymentMethod;
  final int? paymentStatus;
  final String? paymentTransactionId;
  final DateTime? paymentDate;
  final double? amount;
  final String? doctorNotes;
  final String? specializationName;
  final String? doctorProfilePicture;
  final String? patientProfilePicture;
  final DateTime createdAt;

  final bool isCancellationRequested;
  final String? cancellationReason;
  final bool isRescheduleRequested;
  final String? rescheduleReason;
  final DateTime? rescheduleApprovedAt;

  const Appointment({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.doctorId,
    required this.doctorName,
    required this.startTime,
    required this.endTime,
    required this.reason,
    required this.status,
    required this.isPaid,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.paymentTransactionId,
    required this.paymentDate,
    required this.amount,
    required this.doctorNotes,
    this.specializationName,
    this.doctorProfilePicture,
    this.patientProfilePicture,
    required this.createdAt,
    this.isCancellationRequested = false,
    this.cancellationReason,
    this.isRescheduleRequested = false,
    this.rescheduleReason,
    this.rescheduleApprovedAt,
  });
}
