import 'package:doctor_appointment/core/errors/exceptions.dart';
import 'package:doctor_appointment/core/services/api_service.dart';
import 'package:doctor_appointment/features/doctors/data/models/specialization_model.dart';

abstract class SpecializationsRemoteDataSource {
  Future<List<SpecializationModel>> getSpecializations();
}

class SpecializationsRemoteDataSourceImpl
    implements SpecializationsRemoteDataSource {
  final ApiService apiService;
  SpecializationsRemoteDataSourceImpl(this.apiService);

  @override
  Future<List<SpecializationModel>> getSpecializations() async {
    final response = await apiService.get('/api/Doctor/specializations');

    if (response['success'] != true) {
      final msg = response['message'] as String? ?? 'Failed to load specializations';
      throw ApiException(msg);
    }

    final data = response['data'];
    if (data is! List) throw const ApiException('Unexpected specializations payload');

    return data
        .whereType<Map<String, dynamic>>()
        .map(SpecializationModel.fromJson)
        .toList();
  }
}
