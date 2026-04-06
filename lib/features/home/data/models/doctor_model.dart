class DoctorModel {
  final int id;
  final String name;
  final String specialty;
  final double rating;
  final int reviews;
  final String fee;
  final String imageAsset;
  final bool isFavorite;

  const DoctorModel({
    required this.id,
    required this.name,
    required this.specialty,
    required this.rating,
    required this.reviews,
    required this.fee,
    required this.imageAsset,
    this.isFavorite = false,
  });
}
