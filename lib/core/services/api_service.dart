import 'package:dio/dio.dart';

abstract class ApiService {
  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  });
  Future<Map<String, dynamic>> post(String endpoint, {Object? data});
  Future<Map<String, dynamic>> put(String endpoint, {Object? data});
  Future<Map<String, dynamic>> delete(String endpoint, {Object? data});
}

class ApiServiceImpl implements ApiService {
  final Dio _dio;

  ApiServiceImpl(this._dio);

  @override
  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final response = await _dio.get(endpoint, queryParameters: queryParameters);
    return response.data;
  }

  @override
  Future<Map<String, dynamic>> post(String endpoint, {Object? data}) async {
    final response = await _dio.post(endpoint, data: data);
    return response.data;
  }

  @override
  Future<Map<String, dynamic>> put(String endpoint, {Object? data}) async {
    final response = await _dio.put(endpoint, data: data);
    return response.data;
  }

  @override
  Future<Map<String, dynamic>> delete(String endpoint, {Object? data}) async {
    final response = await _dio.delete(endpoint, data: data);
    return response.data;
  }
}
