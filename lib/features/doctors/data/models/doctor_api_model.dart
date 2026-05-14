import 'package:doctor_appointment/features/doctors/data/models/specialization_model.dart';
import 'package:doctor_appointment/features/doctors/domain/entities/doctor.dart';

class DoctorApiModel extends Doctor {
  const DoctorApiModel({
    required super.id,
    required super.fullName,
    required super.email,
    required super.phone,
    required super.specialization,
    required super.bio,
    required super.yearsOfExperience,
    required super.clinicAddress,
    required super.hospital,
    required super.isApproved,
    required super.averageRating,
    required super.totalReviews,
    required super.createdAt,
    required super.specializationId,
    required super.isAvailable,
    required super.profilePictureUrl,
    required super.clinicImagesUrls,
    super.consultationFee,
    super.latitude,
    super.longitude,
  });

  factory DoctorApiModel.fromJson(Map<String, dynamic> json) {
    return DoctorApiModel(
      id: json['id'] as int? ?? 0,
      fullName: json['fullName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      specialization: SpecializationModel(
        id: json['specializationId'] as int? ?? 0,
        name:
            (json['specializationName'] as String?) ??
            (json['specialization'] as String?) ??
            'General',
      ),
      bio: json['bio'] as String?,
      yearsOfExperience: json['yearsOfExperience'] as int?,
      clinicAddress: json['clinicAddress'] as String?,
      hospital: json['hospital'] as String?,
      isApproved:
          (json['isApproved'] as bool?) ?? (json['verified'] as bool?) ?? false,
      averageRating: (json['averageRating'] as num?)?.toDouble(),
      totalReviews: json['totalReviews'] as int? ?? 0,
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      specializationId: json['specializationId'] as int? ?? 0,
      isAvailable: json['isAvailable'] as bool? ?? false,
      profilePictureUrl:
          (json['profilePicture'] as String?) ??
          (json['profilePictureUrl'] as String?),
      clinicImagesUrls:
          ((json['clinicImages'] as List<dynamic>?) ??
                  (json['clinicImagesUrls'] as List<dynamic>?))
              ?.map((e) => e as String)
              .toList(),
      consultationFee: (json['consultationFee'] as num?)?.toDouble(),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }
}
