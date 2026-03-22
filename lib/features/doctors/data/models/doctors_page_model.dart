import 'package:doctor_appointment/features/doctors/data/models/doctor_api_model.dart';
import 'package:doctor_appointment/features/doctors/domain/entities/doctors_page.dart';

class DoctorsPageModel extends DoctorsPage {
  const DoctorsPageModel({
    required super.items,
    required super.totalCount,
    required super.pageNumber,
    required super.pageSize,
    required super.totalPages,
    required super.hasPreviousPage,
    required super.hasNextPage,
  });

  factory DoctorsPageModel.fromJson(Map<String, dynamic> json) {
    final itemsRaw = json['items'];
    final items = itemsRaw is List
        ? itemsRaw
            .whereType<Map<String, dynamic>>()
            .map(DoctorApiModel.fromJson)
            .toList()
        : <DoctorApiModel>[];

    return DoctorsPageModel(
      items: items,
      totalCount: json['totalCount'] as int? ?? 0,
      pageNumber: json['pageNumber'] as int? ?? 1,
      pageSize: json['pageSize'] as int? ?? items.length,
      totalPages: json['totalPages'] as int? ?? 1,
      hasPreviousPage: json['hasPreviousPage'] as bool? ?? false,
      hasNextPage: json['hasNextPage'] as bool? ?? false,
    );
  }
}
