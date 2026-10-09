import 'dart:convert';
import 'package:dio/dio.dart';
import '../../constants/app_constants.dart';
import '../storage/storage_service.dart';

class UserProfileService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: AppConstants.apiBaseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  final StorageService _storage = StorageService();

  /// Get current user's profile
  Future<Map<String, dynamic>> getMyProfile() async {
    try {
      final token = await _storage.getToken();
      
      if (token == null) {
        return {'success': false, 'error': 'No token found'};
      }
      
      final response = await _dio.get(
        '/profile',
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

      return {'success': true, 'profile': data};
    } on DioException catch (e) {
      String errorMsg = 'Failed to fetch profile';
      try {
        final errData = e.response?.data is Map ? e.response!.data : jsonDecode(e.response!.data ?? '{}');
        errorMsg = errData['error'] ?? errorMsg;
      } catch (_) {}
      return {'success': false, 'error': errorMsg};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Update current user's profile
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> profileData) async {
    try {
      final token = await _storage.getToken();
      
      if (token == null) {
        return {'success': false, 'error': 'No token found'};
      }
      
      final response = await _dio.patch(
        '/profile',
        data: profileData,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.data == null || response.data is! Map) {
        throw Exception('Invalid response format');
      }

      return {'success': true, 'profile': response.data};
    } on DioException catch (e) {
      return {
        'success': false,
        'error': e.response?.data['error'] ?? 'Failed to update profile',
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Get another user's profile
  Future<Map<String, dynamic>> getUserProfile(String userId) async {
    try {
      final token = await _storage.getToken();
      
      if (token == null) {
        return {'success': false, 'error': 'No token found'};
      }
      
      final response = await _dio.get(
        '/users/$userId',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      return {'success': true, 'profile': response.data};
    } on DioException catch (e) {
      return {
        'success': false,
        'error': e.response?.data['error'] ?? 'Failed to fetch user profile',
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Search for users
  Future<Map<String, dynamic>> searchUsers(String query) async {
    try {
      final token = await _storage.getToken();
      
      if (token == null) {
        return {'success': false, 'error': 'No token found'};
      }
      
      final response = await _dio.get(
        '/users/search',
        queryParameters: {'q': query},
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      return {'success': true, 'users': response.data['users'] ?? []};
    } on DioException catch (e) {
      return {
        'success': false,
        'error': e.response?.data['error'] ?? 'Failed to search users',
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}
