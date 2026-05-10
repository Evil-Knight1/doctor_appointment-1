import 'package:dio/dio.dart';

abstract class ApiService {
  Future<dynamic> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  });
  Future<dynamic> post(String endpoint, {Object? data});
  Future<dynamic> put(String endpoint, {Object? data});
  Future<dynamic> delete(String endpoint, {Object? data});
}

class ApiServiceImpl implements ApiService {
  final Dio _dio;

  ApiServiceImpl(this._dio);

  @override
  Future<dynamic> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final response = await _dio.get(endpoint, queryParameters: queryParameters);
    return response.data;
  }

  @override
  Future<dynamic> post(String endpoint, {Object? data}) async {
    final response = await _dio.post(endpoint, data: data);
    return response.data;
  }

  @override
  Future<dynamic> put(String endpoint, {Object? data}) async {
    final response = await _dio.put(endpoint, data: data);
    return response.data;
  }

  @override
  Future<dynamic> delete(String endpoint, {Object? data}) async {
    final response = await _dio.delete(endpoint, data: data);
    return response.data;
  }
}
