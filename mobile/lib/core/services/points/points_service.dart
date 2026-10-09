import 'dart:convert';
import 'package:dio/dio.dart';
import '../../constants/app_constants.dart';
import '../storage/storage_service.dart';

class PointsService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: AppConstants.apiBaseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  final StorageService _storage = StorageService();

  /// Get user's current points and recent history
  Future<Map<String, dynamic>> getMyPoints() async {
    try {
      final token = await _storage.getToken();
      if (token == null) return {'success': false, 'error': 'No token found'};

      final response = await _dio.get(
        '/points',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      // Handle both Map and String responses
      Map<String, dynamic> data;
      if (response.data is Map) {
        data = Map<String, dynamic>.from(response.data);
      } else if (response.data is String) {
        data = Map<String, dynamic>.from(jsonDecode(response.data));
      } else {
        throw Exception('Invalid response format');
      }

      if (data.containsKey('error')) {
        return {'success': false, 'error': data['error']};
      }

      return {
        'success': true,
        'totalPoints': data['totalPoints'] ?? 0,
        'recentHistory': data['recentHistory'] ?? [],
      };
    } on DioException catch (e) {
      String errorMsg = 'Failed to get points';
      try {
        final errData = e.response?.data is Map ? e.response!.data : jsonDecode(e.response!.data ?? '{}');
        errorMsg = errData['error'] ?? errorMsg;
      } catch (_) {}
      return {'success': false, 'error': errorMsg};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Get full point history
  Future<Map<String, dynamic>> getPointHistory({int limit = 20}) async {
    try {
      final token = await _storage.getToken();
      if (token == null) return {'success': false, 'error': 'No token found'};

      final response = await _dio.get(
        '/points/history',
        queryParameters: {'limit': limit},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.data == null || response.data is! Map) {
        throw Exception('Invalid response format');
      }
      final Map<String, dynamic> data = Map<String, dynamic>.from(response.data);

      return {
        'success': true,
        'history': data['history'] ?? [],
      };
    } on DioException catch (e) {
      return {'success': false, 'error': e.response?.data?['error'] ?? e.response?.data?.toString() ?? 'Failed to get history'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}
