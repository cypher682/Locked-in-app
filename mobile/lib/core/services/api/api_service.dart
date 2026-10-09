import 'package:dio/dio.dart';
import '../../constants/app_constants.dart';

class ApiService {
  late final Dio _dio;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));
  }

  // UPDATED: Accepts specific 'options' to override defaults (like Auth headers)
  Future<Response> post(String path, {dynamic data, Options? options}) async {
    try {
      return await _dio.post(
        path,
        data: data,
        options: options, // Pass the full Options object directly
      );
    } catch (e) {
      rethrow;
    }
  }

  // UPDATED: Consistent with post
  Future<Response> get(String path, {Options? options}) async {
    try {
      return await _dio.get(
        path,
        options: options,
      );
    } catch (e) {
      rethrow;
    }
  }
}
