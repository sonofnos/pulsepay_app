import 'dart:io';

import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

import 'api_exception.dart';
import 'secure_storage.dart';

class ApiClient {
  ApiClient() : _dio = Dio(BaseOptions(baseUrl: _resolveBaseUrl())) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await SecureStorage.readToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
  }

  final Dio _dio;

  // 10.0.2.2 is the Android emulator's alias for the host's localhost.
  static String _resolveBaseUrl() {
    const envUrl = String.fromEnvironment('PULSEPAY_API_BASE_URL');
    if (envUrl.isNotEmpty) return envUrl;

    if (!Platform.isAndroid) return 'http://127.0.0.1:8123/api';
    return 'http://10.0.2.2:8123/api';
  }

  Future<Map<String, dynamic>> get(String path, {Map<String, dynamic>? query}) async {
    return _unwrap(await _guard(() => _dio.get(path, queryParameters: query)));
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    bool idempotent = false,
  }) async {
    final headers = idempotent ? {'Idempotency-Key': const Uuid().v4()} : null;

    return _unwrap(
      await _guard(() => _dio.post(path, data: body, options: Options(headers: headers))),
    );
  }

  Future<Response> _guard(Future<Response> Function() call) async {
    try {
      return await call();
    } on DioException catch (e) {
      final data = e.response?.data;
      final message = data is Map && data['message'] is String
          ? data['message'] as String
          : 'Something went wrong. Please try again.';
      final errors = data is Map && data['errors'] is Map
          ? Map<String, dynamic>.from(data['errors'] as Map)
          : null;

      throw ApiException(message: message, statusCode: e.response?.statusCode, errors: errors);
    }
  }

  Map<String, dynamic> _unwrap(Response response) {
    final data = response.data;
    if (data is Map<String, dynamic>) return data;
    if (data is List) return {'data': data};
    return {};
  }
}
