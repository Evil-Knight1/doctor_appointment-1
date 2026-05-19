import 'package:doctor_appointment/features/doctors/data/models/doctor_api_model.dart';
import 'package:doctor_appointment/features/doctors/domain/entities/doctor.dart';
import 'package:doctor_appointment/core/utils/image_url_helper.dart';

class HomeDoctorModel {
  final Doctor doctor;
  final bool isFavorite;

  const HomeDoctorModel({required this.doctor, this.isFavorite = false});

  factory HomeDoctorModel.fromJson(Map<String, dynamic> json) {
    return HomeDoctorModel(
      doctor: DoctorApiModel.fromJson(json),
      isFavorite: json['isFavorite'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': doctor.fullName,
      'price': doctor.consultationFee,
      'specialty': doctor.specialization,
      'averageRating': doctor.averageRating,
      'totalReviews': doctor.totalReviews,
      'clinicAddress': doctor.clinicAddress,
      'profilePictureUrl': doctor.profilePictureUrl,
      'clinicImagesUrls': doctor.clinicImagesUrls,
      'isAvailable': doctor.isAvailable,
      'isFavorite': isFavorite,
    };
  }

  String get name => doctor.fullName;
  String get id => doctor.id.toString();
  String get specialty => doctor.specialization.name;
  String get speciality => specialty; // Alias for UI consistency
  String get hospital => doctor.hospital ?? 'Clinic';
  String get price => doctor.consultationFee?.toString() ?? '0';
  double get rating => doctor.averageRating ?? 0.0;
  int get reviewCount => doctor.totalReviews;
  String get reviews => reviewCount.toString(); // For favorite_doctor_card.dart
  String get fee => doctor.consultationFee != null
      ? 'EGP ${doctor.consultationFee!.toInt()}'
      : 'EGP 0';
  String get imageAsset =>
      (doctor.profilePictureUrl != null && doctor.profilePictureUrl!.isNotEmpty)
      ? ImageUrlHelper.getFullUrl(doctor.profilePictureUrl!)
      : 'assets/images/doctor_placeholder.jpg';
  bool get isAvailable => doctor.isAvailable;
}
