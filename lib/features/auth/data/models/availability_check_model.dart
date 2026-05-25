class AvailabilityCheckModel {
  final bool isEmailAvailable;
  final bool isPhoneAvailable;

  const AvailabilityCheckModel({
    required this.isEmailAvailable,
    required this.isPhoneAvailable,
  });

  factory AvailabilityCheckModel.fromJson(Map<String, dynamic> json) {
    return AvailabilityCheckModel(
      isEmailAvailable: json['isEmailAvailable'] as bool? ?? true,
      isPhoneAvailable: json['isPhoneAvailable'] as bool? ?? true,
    );
  }
}
