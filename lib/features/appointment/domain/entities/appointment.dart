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
  final DateTime createdAt;

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
    required this.createdAt,
  });
}
