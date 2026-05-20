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
    super.specializationName,
    super.doctorProfilePicture,
    super.patientProfilePicture,
    required super.createdAt,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    // The backend may nest doctor info under a 'doctor' object or use flat keys
    final doctorObj = json['doctor'] as Map<String, dynamic>?;

    // Doctor name: try flat keys first, then nested doctor object
    final doctorName = json['doctorName'] as String? ??
        json['doctorFullName'] as String? ??
        doctorObj?['fullName'] as String? ??
        doctorObj?['name'] as String? ??
        '';

    // Specialization: may be nested in doctor object or at top level
    final specializationName = json['specializationName'] as String? ??
        json['specialization'] as String? ??
        doctorObj?['specializationName'] as String? ??
        doctorObj?['specialization'] as String?;

    // Doctor profile picture
    final doctorProfilePicture = json['doctorProfilePicture'] as String? ??
        json['profilePicture'] as String? ??
        doctorObj?['profilePicture'] as String? ??
        doctorObj?['profilePictureUrl'] as String?;

    // Patient profile picture
    final patientProfilePicture = json['patientProfilePicture'] as String? ??
        json['patientProfilePictureUrl'] as String?;

    // Patient name
    final patientNameFinal = json['patientName'] as String? ??
        json['patientFullName'] as String? ??
        '';

    return AppointmentModel(
      id: json['id'] as int? ?? 0,
      patientId: json['patientId'] as int? ?? 0,
      patientName: patientNameFinal,
      doctorId: json['doctorId'] as int? ?? doctorObj?['id'] as int? ?? 0,
      doctorName: doctorName,
      startTime:
          DateTime.tryParse(json['startTime'] as String? ?? '') ??
              DateTime.fromMillisecondsSinceEpoch(0),
      endTime: DateTime.tryParse(json['endTime'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      reason: json['reason'] as String? ?? '',
      status: json['status'] as int? ?? 0,
      isPaid: json['isPaid'] as bool? ?? false,
      paymentMethod: json['paymentMethod'] as int?,
      paymentStatus: json['paymentStatus'] as int?,
      paymentTransactionId: json['paymentTransactionId'] as String?,
      paymentDate:
          DateTime.tryParse(json['paymentDate'] as String? ?? ''),
      amount: (json['amount'] as num?)?.toDouble(),
      doctorNotes: json['doctorNotes'] as String?,
      specializationName: specializationName,
      doctorProfilePicture: doctorProfilePicture,
      patientProfilePicture: patientProfilePicture,
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
              DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'patientName': patientName,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'reason': reason,
      'status': status,
      'isPaid': isPaid,
      if (paymentMethod != null) 'paymentMethod': paymentMethod,
      if (paymentStatus != null) 'paymentStatus': paymentStatus,
      if (paymentTransactionId != null) 'paymentTransactionId': paymentTransactionId,
      if (paymentDate != null) 'paymentDate': paymentDate!.toIso8601String(),
      if (amount != null) 'amount': amount,
      if (doctorNotes != null) 'doctorNotes': doctorNotes,
      if (specializationName != null) 'specializationName': specializationName,
      if (doctorProfilePicture != null) 'doctorProfilePicture': doctorProfilePicture,
      if (patientProfilePicture != null) 'patientProfilePicture': patientProfilePicture,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
