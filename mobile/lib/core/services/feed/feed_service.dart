import 'dart:convert';
import 'package:dio/dio.dart';
import '../../constants/app_constants.dart';
import '../storage/storage_service.dart';

class FeedService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: AppConstants.apiBaseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  final StorageService _storage = StorageService();

  /// Get activity feed (friends' check-ins)
  Future<Map<String, dynamic>> getFeed({int limit = 20, int offset = 0}) async {
    try {
      final token = await _storage.getToken();
      
      if (token == null) {
        return {'success': false, 'error': 'No token found'};
      }
      
      final response = await _dio.get(
        '/feed',
        queryParameters: {'limit': limit, 'offset': offset},
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
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
        'feed': data['feed'] ?? [],
        'hasMore': data['hasMore'] ?? false,
      };
    } on DioException catch (e) {
      String errorMsg = 'Failed to fetch feed';
      try {
        final errData = e.response?.data is Map ? e.response!.data : jsonDecode(e.response!.data ?? '{}');
        errorMsg = errData['error'] ?? errorMsg;
      } catch (_) {}
      return {'success': false, 'error': errorMsg};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}
