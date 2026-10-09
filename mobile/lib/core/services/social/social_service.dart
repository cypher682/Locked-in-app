import 'package:dio/dio.dart';
import '../../constants/app_constants.dart';
import '../storage/storage_service.dart';

class SocialService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: AppConstants.apiBaseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  final StorageService _storage = StorageService();

  // ==================== Like Methods ====================

  /// Like a check-in
  Future<Map<String, dynamic>> likeCheckin(String checkinId) async {
    try {
      final token = await _storage.getToken();
      if (token == null) return {'success': false, 'error': 'No token found'};

      await _dio.post(
        '/checkins/$checkinId/like',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return {'success': true};
    } on DioException catch (e) {
      return {'success': false, 'error': e.response?.data['error'] ?? 'Failed to like'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Unlike a check-in
  Future<Map<String, dynamic>> unlikeCheckin(String checkinId) async {
    try {
      final token = await _storage.getToken();
      if (token == null) return {'success': false, 'error': 'No token found'};

      await _dio.delete(
        '/checkins/$checkinId/like',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return {'success': true};
    } on DioException catch (e) {
      return {'success': false, 'error': e.response?.data['error'] ?? 'Failed to unlike'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Get likes for a check-in
  Future<Map<String, dynamic>> getCheckinLikes(String checkinId) async {
    try {
      final token = await _storage.getToken();
      if (token == null) return {'success': false, 'error': 'No token found'};

      final response = await _dio.get(
        '/checkins/$checkinId/likes',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return {
        'success': true,
        'likes': response.data['likes'] ?? [],
        'count': response.data['count'] ?? 0,
        'userLiked': response.data['userLiked'] ?? false,
      };
    } on DioException catch (e) {
      return {'success': false, 'error': e.response?.data['error'] ?? 'Failed to get likes'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // ==================== Comment Methods ====================

  /// Add a comment to a check-in
  Future<Map<String, dynamic>> addComment(String checkinId, String content) async {
    try {
      final token = await _storage.getToken();
      if (token == null) return {'success': false, 'error': 'No token found'};

      final response = await _dio.post(
        '/checkins/$checkinId/comments',
        data: {'content': content},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return {'success': true, 'comment': response.data['comment']};
    } on DioException catch (e) {
      return {'success': false, 'error': e.response?.data['error'] ?? 'Failed to add comment'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Get comments for a check-in
  Future<Map<String, dynamic>> getCheckinComments(String checkinId) async {
    try {
      final token = await _storage.getToken();
      if (token == null) return {'success': false, 'error': 'No token found'};

      final response = await _dio.get(
        '/checkins/$checkinId/comments',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return {
        'success': true,
        'comments': response.data['comments'] ?? [],
        'count': response.data['count'] ?? 0,
      };
    } on DioException catch (e) {
      return {'success': false, 'error': e.response?.data['error'] ?? 'Failed to get comments'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Delete a comment
  Future<Map<String, dynamic>> deleteComment(String commentId) async {
    try {
      final token = await _storage.getToken();
      if (token == null) return {'success': false, 'error': 'No token found'};

      await _dio.delete(
        '/comments/$commentId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return {'success': true};
    } on DioException catch (e) {
      return {'success': false, 'error': e.response?.data['error'] ?? 'Failed to delete comment'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}
