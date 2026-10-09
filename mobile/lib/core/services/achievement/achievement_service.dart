import 'package:dio/dio.dart';
import '../../constants/app_constants.dart';
import '../storage/storage_service.dart';

class AchievementService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: AppConstants.apiBaseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  final StorageService _storage = StorageService();

  /// Get all available achievements
  Future<Map<String, dynamic>> getAllAchievements() async {
    try {
      final token = await _storage.getToken();
      if (token == null) return {'success': false, 'error': 'No token found'};

      final response = await _dio.get(
        '/achievements',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return {
        'success': true,
        'achievements': response.data['achievements'] ?? [],
      };
    } on DioException catch (e) {
      return {'success': false, 'error': e.response?.data['error'] ?? 'Failed to get achievements'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Get user's unlocked achievements
  Future<Map<String, dynamic>> getMyAchievements() async {
    try {
      final token = await _storage.getToken();
      if (token == null) return {'success': false, 'error': 'No token found'};

      final response = await _dio.get(
        '/achievements/mine',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return {
        'success': true,
        'achievements': response.data['achievements'] ?? [],
        'count': response.data['count'] ?? 0,
      };
    } on DioException catch (e) {
      return {'success': false, 'error': e.response?.data['error'] ?? 'Failed to get achievements'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}
