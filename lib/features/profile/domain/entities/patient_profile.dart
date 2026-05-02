class PatientProfile {
  final int id;
  final String fullName;
  final String email;
  final String phone;
  final String? profilePicture;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? address;
  final DateTime createdAt;

  const PatientProfile({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.profilePicture,
    required this.dateOfBirth,
    required this.gender,
    required this.address,
    required this.createdAt,
  });
}
