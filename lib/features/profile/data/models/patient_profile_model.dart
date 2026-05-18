import 'package:doctor_appointment/features/profile/domain/entities/patient_profile.dart';

class PatientProfileModel extends PatientProfile {
  const PatientProfileModel({
    required super.id,
    required super.fullName,
    required super.email,
    required super.phone,
    required super.profilePicture,
    required super.dateOfBirth,
    required super.gender,
    required super.address,
    required super.createdAt,
  });

  factory PatientProfileModel.fromJson(Map<String, dynamic> json) {
    return PatientProfileModel(
      id: (json['id'] is int) ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      fullName: json['fullName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      profilePicture: json['profilePicture']?.toString(),
      dateOfBirth: DateTime.tryParse(json['dateOfBirth']?.toString() ?? ''),
      gender: json['gender']?.toString(),
      address: json['address']?.toString(),
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
              DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      if (profilePicture != null) 'profilePicture': profilePicture,
      if (dateOfBirth != null) 'dateOfBirth': dateOfBirth!.toIso8601String(),
      if (gender != null) 'gender': gender,
      if (address != null) 'address': address,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
