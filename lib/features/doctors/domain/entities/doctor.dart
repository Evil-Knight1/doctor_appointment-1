class Doctor {
  final int id;
  final String fullName;
  final String email;
  final String phone;
  final String? specialization;
  final String? bio;
  final int? yearsOfExperience;
  final String? clinicAddress;
  final String? hospital;
  final bool isApproved;
  final double? averageRating;
  final int totalReviews;
  final DateTime createdAt;

  const Doctor({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.specialization,
    required this.bio,
    required this.yearsOfExperience,
    required this.clinicAddress,
    required this.hospital,
    required this.isApproved,
    required this.averageRating,
    required this.totalReviews,
    required this.createdAt,
  });
}
