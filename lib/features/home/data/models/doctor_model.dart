class DoctorModel {
  final String name;
  final String specialty;
  final double rating;
  final int reviews;
  final String fee;
  final String imageAsset;
  final bool isFavorite;

  const DoctorModel({
    required this.name,
    required this.specialty,
    required this.rating,
    required this.reviews,
    required this.fee,
    required this.imageAsset,
    this.isFavorite = false,
  });

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    return DoctorModel(
      name: json['name'] ?? '',
      specialty: json['specialty'] ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviews: json['reviews'] as int? ?? 0,
      fee: json['fee'] ?? '',
      imageAsset: json['imageAsset'] ?? '',
      isFavorite: json['isFavorite'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'specialty': specialty,
      'rating': rating,
      'reviews': reviews,
      'fee': fee,
      'imageAsset': imageAsset,
      'isFavorite': isFavorite,
    };
  }
}
