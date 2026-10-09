import 'package:dio/dio.dart';
import '../../constants/app_constants.dart';
import '../storage/storage_service.dart';

class FriendshipService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: AppConstants.apiBaseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  final StorageService _storage = StorageService();

  /// Send friend request
  Future<Map<String, dynamic>> sendFriendRequest(String userId) async {
    try {
      final token = await _storage.getToken();
      
      if (token == null) {
        return {'success': false, 'error': 'No token found'};
      }
      
      final response = await _dio.post(
        '/friends/request',
        data: {'addressee_id': userId},
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      return {'success': true, 'message': response.data['message']};
    } on DioException catch (e) {
      return {
        'success': false,
        'error': e.response?.data['error'] ?? 'Failed to send friend request',
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Get friends list
  Future<Map<String, dynamic>> getFriends() async {
    try {
      final token = await _storage.getToken();
      
      if (token == null) {
        return {'success': false, 'error': 'No token found'};
      }
      
      final response = await _dio.get(
        '/friends',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      return {'success': true, 'friends': response.data['friends'] ?? []};
    } on DioException catch (e) {
      return {
        'success': false,
        'error': e.response?.data['error'] ?? 'Failed to fetch friends',
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Get pending friend requests
  Future<Map<String, dynamic>> getPendingRequests() async {
    try {
      final token = await _storage.getToken();
      
      if (token == null) {
        return {'success': false, 'error': 'No token found'};
      }
      
      final response = await _dio.get(
        '/friends/requests',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      return {'success': true, 'requests': response.data['requests'] ?? []};
    } on DioException catch (e) {
      return {
        'success': false,
        'error': e.response?.data['error'] ?? 'Failed to fetch requests',
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Accept friend request
  Future<Map<String, dynamic>> acceptFriendRequest(String friendshipId) async {
    try {
      final token = await _storage.getToken();
      
      if (token == null) {
        return {'success': false, 'error': 'No token found'};
      }
      
      final response = await _dio.post(
        '/friends/$friendshipId/accept',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      return {'success': true, 'message': response.data['message']};
    } on DioException catch (e) {
      return {
        'success': false,
        'error': e.response?.data['error'] ?? 'Failed to accept request',
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Decline friend request
  Future<Map<String, dynamic>> declineFriendRequest(String friendshipId) async {
    try {
      final token = await _storage.getToken();
      
      if (token == null) {
        return {'success': false, 'error': 'No token found'};
      }
      
      final response = await _dio.post(
        '/friends/$friendshipId/decline',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      return {'success': true, 'message': response.data['message']};
    } on DioException catch (e) {
      return {
        'success': false,
        'error': e.response?.data['error'] ?? 'Failed to decline request',
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Remove friend
  Future<Map<String, dynamic>> removeFriend(String friendshipId) async {
    try {
      final token = await _storage.getToken();
      
      if (token == null) {
        return {'success': false, 'error': 'No token found'};
      }
      
      await _dio.delete(
        '/friends/$friendshipId',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      return {'success': true};
    } on DioException catch (e) {
      return {
        'success': false,
        'error': e.response?.data['error'] ?? 'Failed to remove friend',
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}
