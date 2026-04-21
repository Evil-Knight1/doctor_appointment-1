import 'package:doctor_appointment/features/appointment/domain/entities/appointment.dart';

class AppointmentModel extends Appointment {
  const AppointmentModel({
    required super.id,
    required super.patientId,
    required super.patientName,
    required super.doctorId,
    required super.doctorName,
    required super.startTime,
    required super.endTime,
    required super.reason,
    required super.status,
    required super.isPaid,
    required super.paymentMethod,
    required super.paymentStatus,
    required super.paymentTransactionId,
    required super.paymentDate,
    required super.amount,
    required super.doctorNotes,
    required super.createdAt,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'] as int? ?? 0,
      patientId: json['patientId'] as int? ?? 0,
      patientName: json['patientName'] as String? ?? '',
      doctorId: json['doctorId'] as int? ?? 0,
      doctorName: json['doctorName'] as String? ?? '',
      startTime:
          DateTime.tryParse(json['startTime'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      endTime:
          DateTime.tryParse(json['endTime'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      reason: json['reason'] as String? ?? '',
      status: json['status'] as int? ?? 0,
      isPaid: json['isPaid'] as bool? ?? false,
      paymentMethod: json['paymentMethod'] as int?,
      paymentStatus: json['paymentStatus'] as int?,
      paymentTransactionId: json['paymentTransactionId'] as String?,
      paymentDate: DateTime.tryParse(json['paymentDate'] as String? ?? ''),
      amount: (json['amount'] as num?)?.toDouble(),
      doctorNotes: json['doctorNotes'] as String?,
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
