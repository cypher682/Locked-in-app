import 'dart:convert';
import 'package:dio/dio.dart';
import '../../constants/app_constants.dart';
import '../storage/storage_service.dart';

class LeaderboardService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: AppConstants.apiBaseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  final StorageService _storage = StorageService();

  /// Get leaderboard (global or friends)
  Future<Map<String, dynamic>> getLeaderboard({String scope = 'global', int limit = 50}) async {
    try {
      final token = await _storage.getToken();
      if (token == null) return {'success': false, 'error': 'No token found'};

      final response = await _dio.get(
        '/leaderboard',
        queryParameters: {'scope': scope, 'limit': limit},
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
        'leaderboard': data['leaderboard'] ?? [],
        'userRank': data['userRank'],
        'scope': data['scope'],
      };
    } on DioException catch (e) {
      String errorMsg = 'Failed to get leaderboard';
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
